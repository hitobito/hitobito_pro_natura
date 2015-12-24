# encoding: utf-8

#  Copyright (c) 2012-2015, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

class Group::Dachverband < ::Group

  self.layer = true

  self.event_types = [Event, Event::Course]

  # TODO: define actual child group types
  #children Group::Root

  ### ROLES

  class PlJugend < ::Role
    self.permissions = [:layer_and_below_full, :admin, :contact_data]
  end

  roles PlJugend

end
