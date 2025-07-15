# encoding: utf-8

#  Copyright (c) 2025, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require "spec_helper"

describe Person::Mutations::Mutation do
  let(:group) { groups(:thun) }
  let(:person) { Fabricate(Group::Jugendgruppe::Leader.name, group: group).person }

  subject { Person::Mutations::Mutation.new(version, person) }

  context "person change" do
    let(:version) { PaperTrail::Version.create!(item: person, main: person, event: :update) }

    it "resolves phone number" do
      person.phone_numbers.create!(number: "+41 79 000 00 00", label: "Privat")
      expect(subject.phone_number_private).to eq("+41 79 000 00 00")
      expect(subject.phone_number_mobile).to be_nil
    end

    it "resolves primary group" do
      expect(subject.primary_group).to eq(group.to_s)
    end

    it "resolves primary layer" do
      expect(subject.primary_layer).to eq(groups(:thun).to_s)
    end

    it "resolves roles" do
      expect(subject.primary_roles).to eq(["Leiter/in"])
    end

    it "resolves role changes" do
      expect(subject.role_changes).to be_falsey
    end

    it "stores role and group info" do
      expect(subject.primary_roles).to eq ["Leiter/in"]
      expect(subject.primary_layer).to eq 'Thun "Alpendohlen"'
      expect(subject.primary_group).to eq 'Thun "Alpendohlen"'
    end
  end

  context "role changes" do
    let(:version) { PaperTrail::Version.create!(item: person.roles.first, main: person, event: :update) }

    it "resolves role changes" do
      expect(subject.role_changes).to be_truthy
    end
  end

  context "role is deleted" do
    let(:version) { PaperTrail::Version.create!(item: person, main: person, event: :update) }

    subject { Person::Mutations::Mutation.new(version, person, true) }

    before do
      person.roles.update_all end_on: "2025-07-05"
    end

    it "stores last role and group info" do
      expect(subject.primary_roles).to eq ["Leiter/in (bis 05.07.2025)"]
      expect(subject.primary_layer).to eq 'Thun "Alpendohlen"'
      expect(subject.primary_group).to eq 'Thun "Alpendohlen"'
    end
  end
end
