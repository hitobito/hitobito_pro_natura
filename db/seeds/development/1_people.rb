# encoding: utf-8

#  Copyright (c) 2012-2015, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require Rails.root.join('db', 'seeds', 'support', 'person_seeder')

class ProNaturaPersonSeeder < PersonSeeder

  def amount(role_type)
    case role_type.name.demodulize
    when 'Member' then 5
    else 1
    end
  end

end

puzzlers = [
  'Andre Kunz',
  'Andreas Maierhofer',
  'Mathis Hofer',
  'Matthias Viehweger',
  'Pascal Simon',
  'Pascal Zumkehr',
  'Roland Studer',
]

devs = {'Fabian Lippuner' => 'fabian.lippuner@pronatura.ch'}
puzzlers.each do |puz|
  devs[puz] = "#{puz.split.last.downcase}@puzzle.ch"
end

seeder = ProNaturaPersonSeeder.new

seeder.seed_all_roles

root = Group.root
devs.each do |name, email|
  seeder.seed_developer(name, email, root, Group::Dachverband::PlJugend)
end
