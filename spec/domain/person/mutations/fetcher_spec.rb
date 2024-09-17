#  Copyright (c) 2016, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require "spec_helper"

describe Person::Mutations::Fetcher, versioning: true do
  before do
    @created = Fabricate(:person, first_name: "@created").tap do
      Fabricate(Group::Jugendgruppe::Member.name, person: _1, group: groups(:thun))
    end
    @updated = Fabricate(:person, first_name: "@updated").tap do
      Fabricate(Group::Jugendgruppe::Member.name, person: _1, group: groups(:thun))
    end
    @updated.update_column(:created_at, 1.year.ago)
    @multi_roles = Fabricate(:person, first_name: "@multi_roles").tap do
      Fabricate(Group::Jugendgruppe::Member.name, person: _1, group: groups(:thun), start_on: 2.months.ago, end_on: 1.month.ago)
      Fabricate(Group::Sektion::Admin.name, person: _1, group: groups(:be))
    end

    @before = create_past(first_name: "@before")
    @phone_changed = create_past(first_name: "@phone_changed")
    @phone_changed.phone_numbers.create!(number: "+41790000000", label: "Privat")
    @role_added = create_past(first_name: "@role_added").tap do
      Fabricate(Group::Sektion::Admin.name, group: groups(:be), person: _1)
    end
    @role_deleted = create_past([Group::Jugendgruppe::Member, groups(:thun)], [Group::Sektion::Admin, groups(:be)],
      first_name: "@role_deleted").tap do
      _1.roles.where(group: groups(:thun)).each {|r| r.update!(end_on: Date.current.yesterday) }
    end
    @primary_group_changed = create_past([Group::Jugendgruppe::Member, groups(:thun)], [Group::Sektion::Admin, groups(:be)],
                                         first_name: "@primary_group_changed").tap do
      _1.update!(primary_group_id: groups(:be).id)
    end
    @deleted = Fabricate(:person, first_name: "@deleted").tap do
      Fabricate(Group::Jugendgruppe::Member.name, person: _1, group: groups(:thun), start_on: 2.months.ago, end_on: 1.month.ago)
    end
    @deleted_longtime = Fabricate(:person, first_name: "@deleted_longtime").tap do
      Fabricate(Group::Jugendgruppe::Member.name, person: _1, group: groups(:thun), start_on: 2.years.ago, end_on: 1.year.ago)
    end
    @deleted_multi = Fabricate(:person, first_name: "@deleted_multi").tap do
      Fabricate(Group::Jugendgruppe::Member.name, person: _1, group: groups(:thun), start_on: 2.years.ago, end_on: 1.year.ago)
      Fabricate(Group::Sektion::Admin.name, person: _1, group: groups(:be), start_on: 2.months.ago, end_on: 1.month.ago)
    end
    @passive = Fabricate(:person, first_name: "@passive").tap do
      Fabricate(Group::JugendgruppePassive::Member.name, person: _1, group: groups(:thun_passive))
    end
    @passive_deleted = Fabricate(:person, first_name: "@passive_deleted").tap do
      Fabricate(Group::JugendgruppePassive::Member.name, person: _1, group: groups(:thun_passive))
      Fabricate(Group::Jugendgruppe::Member.name, person: _1, group: groups(:thun), start_on: 2.years.ago, end_on: 1.year.ago)
    end
    @passive_deleted_recently = Fabricate(:person, first_name: "@passive_deleted_recently").tap do
      Fabricate(Group::Jugendgruppe::Member.name, person: _1, group: groups(:thun), start_on: 2.years.ago, end_on: 1.year.ago)
      Fabricate(Group::JugendgruppePassive::Member.name, person: _1, group: groups(:thun_passive), start_on: 2.months.ago, end_on: 1.month.ago)
    end
  end

  def create_past(*roles, **person_attrs)
    roles = [[Group::Jugendgruppe::Member, groups(:thun)]] if roles.blank?

    Fabricate(:person, **person_attrs.reverse_merge(created_at: 1.year.ago, updated_at: 1.year.ago)).tap do |person|
      roles.each do |role, group|
        Fabricate(role.name, group: group, person: person, created_at: 1.year.ago, updated_at: 1.year.ago)
      end
      person.versions.update_all(created_at: 1.year.ago)
      person.reload
    end
  end

  let(:fetcher) { Person::Mutations::Fetcher.new(3.months.ago) }

  context "#mutated_people" do
    subject { fetcher.mutated_people.collect(&:to_s) }

    it "contains only changed people" do
      is_expected.to match_array([@created,
        @updated,
        @multi_roles,
        @phone_changed,
        @role_added,
        @role_deleted,
        @primary_group_changed].collect(&:to_s))
    end
  end

  context "#deleted_people" do
    subject { fetcher.deleted_people.collect(&:to_s) }

    it "contains only deleted" do
      is_expected.to match_array([@deleted,
        @deleted_multi].collect(&:to_s))
    end
  end

  context "#fetch" do
    subject { fetcher.fetch }

    it "contains all people" do
      expect(subject.collect(&:to_s)).to match_array([@deleted,
        @deleted_multi,
        @created,
        @updated,
        @multi_roles,
        @phone_changed,
        @role_added,
        @role_deleted,
        @primary_group_changed].collect(&:to_s))
    end

    it "contains changeset for update" do
      modification = subject.find { |m| m.id == @primary_group_changed.id }
      expect(modification.changed_at).to be_within(1).of(@primary_group_changed.updated_at)
      expect(modification.kind).to eq(:updated)
      expect(modification.changeset).to eq("primary_group_id" => [groups(:thun).id, groups(:be).id])
      expect(modification.role_changes).to eq(false)
    end

    it "contains changeset for create" do
      modification = subject.find { |m| m.id == @created.id }
      expect(modification.changed_at).to be_within(1).of(@created.created_at)
      expect(modification.kind).to eq(:created)
      expect(modification.changeset).to be_present
      expect(modification.role_changes).to eq(true)
    end

    it "contains no changeset for delete" do
      modification = subject.find { |m| m.id == @deleted_multi.id }
      role = @deleted_multi.roles.with_inactive.to_a.find { |r| r.group_id == groups(:be).id }
      expect(modification.changed_at).to eq role.end_on.beginning_of_day
      expect(modification.kind).to eq(:deleted)
      expect(modification.changeset).to eq({})
      expect(modification.role_changes).to eq(nil)
    end

    it "contains changeset for phone number" do
      modification = subject.find { |m| m.id == @phone_changed.id }
      expect(modification.kind).to eq(:updated)
      expect(modification.changeset["number"]).to eq([nil, "+41 79 000 00 00"])
      expect(modification.changeset["label"]).to eq([nil, "Privat"])
      expect(modification.role_changes).to eq(false)
    end

    it "contains changeset for role added" do
      modification = subject.find { |m| m.id == @role_added.id }
      role = @role_added.roles.find { |r| r.group_id == groups(:be).id }
      expect(modification.changed_at).to be_within(0.01).of(role.created_at)
      expect(modification.kind).to eq(:updated)
      expect(modification.changeset.keys).to have(5).items
      expect(modification.role_changes).to eq(true)
    end

    it "contains changeset for role deleted" do
      modification = subject.find { |m| m.id == @role_deleted.id }
      role = @role_deleted.roles.with_inactive.find { |r| r.group_id == groups(:thun).id }
      expect(modification.changed_at).to eq role.updated_at
      expect(modification.kind).to eq(:updated)
      expect(modification.changeset).to eq("end_on" => [nil, role.end_on])
      expect(modification.role_changes).to eq(true)
    end
  end
end
