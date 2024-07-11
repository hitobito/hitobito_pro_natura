#  Copyright (c) 2016, Pro Natura Schweiz. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

module ProNatura::Sheet::Group
  extend ActiveSupport::Concern

  included do
    tabs.insert(
      -2,
      Sheet::Tab.new("groups.tabs.mutations",
        :group_mutations_path,
        if: lambda do |view, group|
          group.is_a?(Group::Dachverband) && view.can?(:index_mutations, group)
        end)
    )
  end
end
