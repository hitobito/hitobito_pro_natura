# frozen_string_literal: true

#  Copyright (c) 2023, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

class SetLanguageDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:people, :language, from: nil, to: 'de')
  end
end
