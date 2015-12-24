# encoding: utf-8

#  Copyright (c) 2012-2015, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

class Group::Jugendgruppe < ::Group

  self.layer = true

  children Group::JugendgruppeGremium,
           Group::JugendgruppePassive

  ### ROLES

  class Admin < ::Role
    self.permissions = [:layer_and_below_full, :contact_data]
  end

  class Leader < ::Role
    self.permissions = [:layer_and_below_read, :contact_data]
  end

  class Member < ::Role
    self.permissions = []
  end

  roles Leader, Member, Admin

end
