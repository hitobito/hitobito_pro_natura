# encoding: utf-8

#  Copyright (c) 2016, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require 'spec_helper'

describe Person::Mutations::Fetcher, versioning: true do

  before do
    @created = Fabricate(Group::Jugendgruppe::Member.name, group: groups(:thun)).person
    @updated = Fabricate(Group::Jugendgruppe::Member.name, group: groups(:thun)).person
    @updated.update_column(:created_at, 1.year.ago)
    @multi_roles = Fabricate(Group::Jugendgruppe::Member.name, group: groups(:thun), deleted_at: 1.month.ago).person
    Fabricate(Group::Sektion::Admin.name, group: groups(:be), person: @multi_roles)
    @before = create_past
    @phone_changed = create_past
    @phone_changed.phone_numbers.create!(number: '+41790000000', label: 'Privat')
    @role_added = create_past
    Fabricate(Group::Sektion::Admin.name, group: groups(:be), person: @role_added)
    @role_deleted = create_past([Group::Jugendgruppe::Member, groups(:thun)], [Group::Sektion::Admin, groups(:be)])
    @role_deleted.roles.where(group: groups(:thun)).destroy_all
    @primary_group_changed = create_past([Group::Jugendgruppe::Member, groups(:thun)], [Group::Sektion::Admin, groups(:be)])
    @primary_group_changed.update!(primary_group_id: groups(:be).id)
    @deleted = Fabricate(Group::Jugendgruppe::Member.name, group: groups(:thun), deleted_at: 1.month.ago).person
    @deleted_longtime = Fabricate(Group::Jugendgruppe::Member.name, group: groups(:thun), deleted_at: 1.year.ago).person
    @deleted_multi = Fabricate(Group::Jugendgruppe::Member.name, group: groups(:thun), deleted_at: 1.year.ago).person
    Fabricate(Group::Sektion::Admin.name, group: groups(:be), deleted_at: 1.month.ago, person: @deleted_multi)
    @passive = Fabricate(Group::JugendgruppePassive::Member.name, group: groups(:thun_passive)).person
    @passive_deleted = Fabricate(Group::JugendgruppePassive::Member.name, group: groups(:thun_passive)).person
    Fabricate(Group::Jugendgruppe::Member.name, group: groups(:thun), person: @passive_deleted, deleted_at: 1.year.ago)
    @passive_deleted_recently = Fabricate(Group::Jugendgruppe::Member.name, group: groups(:thun), deleted_at: 1.year.ago).person
    Fabricate(Group::JugendgruppePassive::Member.name, group: groups(:thun_passive), person: @passive_deleted_recently, deleted_at: 1.month.ago)
  end

  def create_past(*roles)
    roles = [[Group::Jugendgruppe::Member, groups(:thun)]] if roles.blank?

    Fabricate(:person, created_at: 1.year.ago, updated_at: 1.year.ago).tap do |person|
      roles.each do |role, group|
        Fabricate(role.name, group: group, person: person, created_at: 1.year.ago, updated_at: 1.year.ago)
      end
      person.versions.update_all(created_at: 1.year.ago)
      person.reload
    end
  end

  let(:fetcher) { Person::Mutations::Fetcher.new(3.months.ago) }

  context '#mutated_people' do
    subject { fetcher.mutated_people.collect(&:to_s) }

    it 'contains only changed people' do
      is_expected.to match_array([@created,
                                  @updated,
                                  @multi_roles,
                                  @phone_changed,
                                  @role_added,
                                  @role_deleted,
                                  @primary_group_changed].collect(&:to_s))
    end
  end

  context '#deleted_people' do
    subject { fetcher.deleted_people.collect(&:to_s) }

    it 'contains only deleted' do
      is_expected.to match_array([@deleted,
                                  @deleted_multi].collect(&:to_s))
    end
  end

  context '#fetch' do
    subject { fetcher.fetch }

    it 'contains all people' do
      expect(subject.collect(&:to_s)).to match_array([@deleted,
                                                      @deleted_multi,
                                                      @created,
                                                      @updated,
                                                      @multi_roles,
                                                      @phone_changed,
                                                      @role_added,
                                                      @role_deleted,
                                                      @primary_group_changed
                                                      ].collect(&:to_s))
    end

    it 'contains changeset for update' do
      modification = subject.find { |m| m.id == @primary_group_changed.id }
      expect(modification.changed_at).to be_within(1).of(@primary_group_changed.updated_at)
      expect(modification.kind).to eq(:updated)
      expect(modification.changeset).to eq('primary_group_id' => [groups(:thun).id, groups(:be).id])
      expect(modification.role_changes).to eq(false)
    end

    it 'contains changeset for create' do
      modification = subject.find { |m| m.id == @created.id }
      expect(modification.changed_at).to be_within(1).of(@created.created_at)
      expect(modification.kind).to eq(:created)
      expect(modification.changeset).to be_present
      expect(modification.role_changes).to eq(true)
    end

    it 'contains no changeset for delete' do
      modification = subject.find { |m| m.id == @deleted_multi.id }
      role = @deleted_multi.roles.with_deleted.to_a.find { |r| r.group_id == groups(:be).id }
      expect(modification.changed_at).to be_within(0.01).of(role.deleted_at)
      expect(modification.kind).to eq(:deleted)
      expect(modification.changeset).to eq({})
      expect(modification.role_changes).to eq(nil)
    end

    it 'contains changeset for phone number' do
      modification = subject.find { |m| m.id == @phone_changed.id }
      expect(modification.kind).to eq(:updated)
      expect(modification.changeset['number']).to eq([nil, '+41790000000'])
      expect(modification.changeset['label']).to eq([nil, 'Privat'])
      expect(modification.role_changes).to eq(false)
    end

    it 'contains changeset for role added' do
      modification = subject.find { |m| m.id == @role_added.id }
      role = @role_added.roles.find { |r| r.group_id == groups(:be).id }
      expect(modification.changed_at).to be_within(0.01).of(role.created_at)
      expect(modification.kind).to eq(:updated)
      expect(modification.changeset.keys).to have(5).items
      expect(modification.role_changes).to eq(true)
    end

    it 'contains changeset for role deleted' do
      modification = subject.find { |m| m.id == @role_deleted.id }
      role = @role_deleted.roles.with_deleted.find { |r| r.group_id == groups(:thun).id }
      expect(modification.changed_at).to be_within(0.01).of(role.deleted_at)
      expect(modification.kind).to eq(:updated)
      expect(modification.changeset).to eq({})
      #binding.pry
      expect(modification.role_changes).to eq(true)
    end

  end


end
