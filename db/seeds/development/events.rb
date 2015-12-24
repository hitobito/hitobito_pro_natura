# encoding: utf-8

#  Copyright (c) 2012-2015, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require Rails.root.join('db', 'seeds', 'support', 'event_seeder')

srand(42)

class ProNaturaEventSeeder < EventSeeder

  def seed_course(values)
    event = super(values)
    event.reload
    event.state = Event::Course.possible_states.shuffle.first
    event.save!
  end
end

seeder = ProNaturaEventSeeder.new

layer_types = Group.all_types.select(&:layer).collect(&:sti_name)
Group.where(type: layer_types).pluck(:id).each do |group_id|
  5.times do
    seeder.seed_event(group_id, :base)
  end
end

seeder.course_group_ids.each do |group_id|
  3.times do
    seeder.seed_event(group_id, :course)
  end
end
