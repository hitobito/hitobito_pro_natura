#  Copyright (c) 2016, Pro Natura Schweiz. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

module ProNatura::GroupAbility
  extend ActiveSupport::Concern

  included do
    on(Group) do
      permission(:layer_and_below_read).may(:index_mutations).in_same_layer_or_below
      general(:index_mutations).only_dachverband
    end
  end

  def only_dachverband
    group.is_a?(Group::Dachverband)
  end
end
