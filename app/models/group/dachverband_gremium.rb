# encoding: utf-8

#  Copyright (c) 2012-2015, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

class Group::DachverbandGremium < ::Group

  children Group::DachverbandGremium

  ### ROLES

  class Leader < ::Role
    self.permissions = [:layer_and_below_read, :group_and_below_full, :contact_data]
  end

  class Member < ::Role
    self.permissions = [:layer_read, :contact_data]
  end

  roles Leader, Member

end
