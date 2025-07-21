#  Copyright (c) 2016, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require "spec_helper"

describe Person::Mutations::Fetcher, versioning: true do
  before do
    @created = Fabricate(:person, first_name: "@created").tap do
      Fabricate(Group::Jugendgruppe::Leader.name, person: _1, group: groups(:thun))
    end
    @updated = Fabricate(:person, first_name: "@updated").tap do
      Fabricate(Group::Jugendgruppe::Leader.name, person: _1, group: groups(:thun))
    end
    @updated.update_column(:created_at, 1.year.ago)
    @multi_roles = Fabricate(:person, first_name: "@multi_roles").tap do
      Fabricate(Group::Jugendgruppe::Leader.name, person: _1, group: groups(:thun), start_on: 2.months.ago, end_on: 1.month.ago)
      Fabricate(Group::DachverbandGremium::Leader.name, person: _1, group: groups(:gs))
    end

    @before = create_past(first_name: "@before")
    @phone_changed = create_past(first_name: "@phone_changed")
    @phone_changed.phone_numbers.create!(number: "+41790000000", label: "Privat")
    @role_added = create_past(first_name: "@role_added").tap do
      Fabricate(Group::Sektion::Admin.name, group: groups(:be), person: _1)
    end
    @role_deleted = create_past([Group::Jugendgruppe::Leader, groups(:thun)], [Group::DachverbandGremium::Leader, groups(:gs)],
      first_name: "@role_deleted").tap do
      _1.roles.where(group: groups(:thun)).each {|r| r.update!(end_on: Date.current.yesterday) }
    end
    @primary_group_changed = create_past([Group::Jugendgruppe::Leader, groups(:thun)], [Group::DachverbandGremium::Leader, groups(:gs)],
                                         first_name: "@primary_group_changed").tap do
      _1.update!(primary_group_id: groups(:be).id)
    end
    @deleted = Fabricate(:person, first_name: "@deleted").tap do
      Fabricate(Group::Jugendgruppe::Leader.name, person: _1, group: groups(:thun), start_on: 2.months.ago, end_on: 1.month.ago)
    end
    @deleted_longtime = Fabricate(:person, first_name: "@deleted_longtime").tap do
      Fabricate(Group::Jugendgruppe::Leader.name, person: _1, group: groups(:thun), start_on: 2.years.ago, end_on: 1.year.ago)
    end
    @deleted_multi = Fabricate(:person, first_name: "@deleted_multi").tap do
      Fabricate(Group::Jugendgruppe::Leader.name, person: _1, group: groups(:thun), start_on: 2.years.ago, end_on: 1.year.ago)
      Fabricate(Group::DachverbandGremium::Leader.name, person: _1, group: groups(:gs), start_on: 2.months.ago, end_on: 1.month.ago)
    end
    @mutation_after_role_is_deleted = create_past([Group::Jugendgruppe::Leader, groups(:thun)], first_name: "@mutation_after_role_is_deleted").tap do
      _1.roles.where(group: groups(:thun)).each {|r| r.update!(end_on: 1.week.ago) }
      _1.phone_numbers.create!(number: "+41790000000", label: "Privat")
    end
    @passive = Fabricate(:person, first_name: "@passive").tap do
      Fabricate(Group::JugendgruppePassive::Member.name, person: _1, group: groups(:thun_passive))
    end
  end

  def create_past(*roles, **person_attrs)
    roles = [[Group::Jugendgruppe::Leader, groups(:thun)]] if roles.blank?

    Fabricate(:person, **person_attrs.reverse_merge(created_at: 1.year.ago, updated_at: 1.year.ago)).tap do |person|
      roles.each do |role, group|
        Fabricate(role.name, group: group, person: person, created_at: 1.year.ago, updated_at: 1.year.ago)
      end
      person.versions.update_all(created_at: 1.year.ago)
      person.reload
    end
  end

  let(:fetcher) { Person::Mutations::Fetcher.new(3.months.ago) }

  context "#mutations" do
    subject { fetcher.mutations }

    it "contains all relevant changes" do
      expected = [
        @deleted,
        @deleted_multi,
        @created,
        @updated,
        @multi_roles,
        @phone_changed,
        @role_added,
        @role_deleted,
        @primary_group_changed,
        @mutation_after_role_is_deleted
      ].map(&:to_s)

      expect(subject.map(&:to_s)).to include(*expected)
    end

    it "contains multiple entries when multiple changes were applied" do
      expect(subject.map(&:to_s).count(@updated.to_s)).to eq 2
      expect(subject.map(&:to_s).count(@multi_roles.to_s)).to eq 3
      expect(subject.map(&:to_s).count(@deleted.to_s)).to eq 3
    end

    it "does not contain changes on people with passive roles" do
      expect(subject.map(&:to_s)).not_to include(@passive.to_s)
    end

    it "contains changeset for update" do
      modification = subject.find { |m| m.id == @primary_group_changed.id }
      expect(modification.changed_at).to be_within(1).of(@primary_group_changed.updated_at)
      expect(modification.kind).to eq(:updated)
      expect(modification.changeset).to eq("primary_group_id" => [groups(:thun).id, groups(:be).id])
      expect(modification.role_changes).to be_falsey
    end

    it "contains changeset for create" do
      modification = subject.find { |m| m.id == @created.id }
      expect(modification.changed_at).to be_within(1).of(@created.created_at)
      expect(modification.kind).to eq(:created)
      expect(modification.changeset).to be_present
      expect(modification.role_changes).to be_falsey
    end

    it "contains changeset for delete" do
      modification = subject.find { |m| m.id == @deleted_multi.id }
      role = @deleted_multi.roles.with_inactive.to_a.find { |r| r.group_id == groups(:gs).id }
      expect(modification.changed_at).to eq role.end_on.beginning_of_day
      expect(modification.kind).to eq(:deleted)
      expect(modification.changeset).to eq({})
      expect(modification.role_changes).to be_falsey
      expect(modification.primary_roles.first).to start_with "Leiter/in (bis"
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
      expect(modification.changeset.keys).to have(6).items
      expect(modification.role_changes).to be_truthy
    end

    it "contains changeset for role deleted" do
      modification = subject.find { |m| m.id == @role_deleted.id }
      role = @role_deleted.roles.with_inactive.find { |r| r.group_id == groups(:thun).id }
      expect(modification.changed_at).to eq role.updated_at
      expect(modification.kind).to eq(:updated)
      expect(modification.changeset).to eq("end_on" => [nil, role.end_on])
      expect(modification.role_changes).to be_truthy
    end

    it "contains changeset for changes, even when role was deleted" do
      modification = subject.find { |m| m.id == @mutation_after_role_is_deleted.id && m.changeset.keys.include?("number") }
      expect(modification.kind).to eq(:updated)
      expect(modification.primary_roles).to eq ["Leiter/in (bis #{1.week.ago.strftime('%d.%m.%Y')})"]
    end
  end
end
