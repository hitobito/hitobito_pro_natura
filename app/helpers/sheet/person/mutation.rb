#  Copyright (c) 2016, Pro Natura Schweiz. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

module Sheet
  class Person < Base
    class Mutation < Base
      self.parent_sheet = Sheet::Group
    end
  end
end
