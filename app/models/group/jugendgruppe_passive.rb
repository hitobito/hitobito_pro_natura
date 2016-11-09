# encoding: utf-8

#  Copyright (c) 2012-2015, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

class Group::JugendgruppePassive < ::Group

  children Group::JugendgruppePassive

  ### ROLES

  class Admin < ::Role
    self.permissions = [:group_and_below_full]
  end

  class Member < ::Role
    self.permissions = []
  end

  roles Admin, Member

end
