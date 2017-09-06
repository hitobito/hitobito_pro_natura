# encoding: utf-8

#  Copyright (c) 2012-2015, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require Rails.root.join('db', 'seeds', 'support', 'group_seeder')

seeder = GroupSeeder.new

root = Group.roots.first
srand(42)

unless root.address.present?
  # avoid callbacks to prevent creating default groups twice
  root.update_columns(seeder.group_attributes)

  root.default_children.each do |child_class|
    child_class.first.update_attributes(seeder.group_attributes)
  end
end

gremien = Group::DachverbandGremium.seed(:name, :parent_id,
                                         { name: 'Geschäftsleitung',
                                           address: "Klostergasse 3",
                                           zip_code: "3333",
                                           town: "Bern",
                                           country: "CH",
                                           email: "gs@pronatura.example.ch",
                                           parent_id: root.id})

sektionen = Group::Sektion.seed(:name, :parent_id,
                                { name: 'Bern', short_name: 'BE',  parent_id: root.id },
                                { name: 'Zürich', short_name: 'ZH',  parent_id: root.id })

jg = Group::Jugendgruppe.seed(:name, :parent_id,
                              { name: 'Thun "Alpendohlen"',  parent_id: sektionen[0].id },
                              { name: 'Jura Bernois',  parent_id: sektionen[0].id },
                              { name: 'Zürich "Natrix"',  parent_id: sektionen[1].id },
                              { name: 'Basel "Grieni Kääfer"',  parent_id: root.id })

Group::JugendgruppePassive.seed(:name, :parent_id,
                                { name: 'Passive', parent_id: jg[0].id })

Group::JugendgruppeGremium.seed(:name, :parent_id,
                                { name: 'Kyburg Gitzenis', parent_id: jg[0].id })

Group.rebuild!
