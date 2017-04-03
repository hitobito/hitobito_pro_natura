# encoding: utf-8

#  Copyright (c) 2016 Pro Natura Schweiz. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.


module Export::Tabular::People
  class Mutations < Export::Tabular::Base

    include Translatable

    self.row_class = MutationRow
    self.model_class = Person

    def attributes
      [:kind, :changed_at, :changeset,
       :primary_roles, :role_changes, :primary_layer, :primary_group,
       :adress_nummer, :first_name, :last_name, :address, :country, :zip_code, :town,
       :phone_number_private, :phone_number_mobile, :email]
    end

    private

    def attribute_label(attr)
      translate(attr)
    end

  end
end
