# encoding: utf-8

#  Copyright (c) 2016, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require "spec_helper"

describe Export::Tabular::People::Mutations do

  let(:mutations) { [] }

  let(:exporter) { described_class.new(mutations) }

  context "#attribute_labels" do
    subject { exporter.attribute_labels }

    it "contains translated attribute labels" do
      expect(subject[:first_name]).to eq "vorname1"
      expect(subject[:phone_number_private]).to eq "telp"
    end
  end

  context "#csv", versioning: true do
    let(:p1) { Fabricate(Group::Jugendgruppe::Member.name, group: groups(:thun)).person }
    let(:p2) { Fabricate(Group::Jugendgruppe::Member.name, group: groups(:thun)).person }
    let(:p3) { Fabricate(Group::Jugendgruppe::Member.name, group: groups(:thun)).person }

    let(:mutations) do
      [Person::Mutations::Mutation.new(p1.versions.last, p1),
       Person::Mutations::Mutation.new(p2.roles.first.versions.last, p2),
       Person::Mutations::Mutation.new(PaperTrail::Version.new(event: :delete, created_at: p3.created_at, item_id: p3, item_type: Person.sti_name), p3)]
    end

    subject { exporter.data_rows.to_a }

    it "renders complete header" do
      expect(exporter.labels).to eq(["Mutationsart", "Mutationsdatum", "Mutation", "Rollen",
                                   "Rollenanpassung", "Hauptebene", "Hauptgruppe",
                                   "adrnr", "vorname1", "nachname1", "strasse", "land",
                                   "plz", "ort", "telp", "mobilep", "emailp"])
    end

    it "renders all values" do
      p1.phone_numbers.create!(number: "+41790000000", label: "Mobil")
      p2.phone_numbers.create!(number: "+41791111111", label: "Arbeit")

      changeset = {
        first_name: "Vorname",
        last_name: "Nachname",
        nickname: "Übername",
        email: "Haupt-E-Mail"
      }.collect { |attr, label| "#{label}: nil -> \"#{p1.send(attr)}\"" }.join(", ")

      expect(subject.first).to eq(["neu", format_date_time(p1.created_at), changeset,
                                    "Aktivmitglied", "nein", groups(:thun).name, groups(:thun).name,
                                    nil, p1.first_name, p1.last_name, p1.address, p1.country,
                                    p1.zip_code, p1.town, nil, "+41 79 000 00 00", p1.email])

      expect(subject.third).to eq(["gelöscht", format_date_time(p3.created_at), "",
                                    "Aktivmitglied", "nein", groups(:thun).name, groups(:thun).name,
                                    nil, p3.first_name, p3.last_name, p3.address, p3.country,
                                    p3.zip_code, p3.town, nil, nil, p3.email])
    end

    it "renders changeset of role" do
      expect(subject.second[2]).to start_with(
         "Id: nil -> #{p2.roles.first.id}, " \
         "Person: nil -> #{p2.id}, " \
         "Group: nil -> #{groups(:thun).id}, " \
         'Type: nil -> "Group::Jugendgruppe::Member", ')
    end

    def format_date_time(value)
      "#{I18n.l(value.to_date)} #{I18n.l(value, format: :time)}"
    end

  end

end
