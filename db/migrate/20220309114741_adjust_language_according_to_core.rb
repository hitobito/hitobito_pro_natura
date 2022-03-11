# frozen_string_literal: true

#  Copyright (c) 2012-2022, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

class AdjustLanguageAccordingToCore < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:people, :language, false, 'de')

    Person.where(language: '').update(language: 'de')

    Person.find_each do |person|
      person.update!(language: person.language.downcase)
    end
  end
end
