# encoding: utf-8

#  Copyright (c) 2012-2016, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

class AddAdressNummerSpracheToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :adress_nummer, :string

    unless ActiveRecord::Base.connection.column_exists?(:people, :language)
      add_column :people, :language, :string, limit: 2
    end
  end
end
