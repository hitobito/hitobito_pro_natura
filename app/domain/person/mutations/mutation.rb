# encoding: utf-8

#  Copyright (c) 2016 Pro Natura Schweiz. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

module Person::Mutations
  class Mutation

    PERSON_ATTRS = [:id, :first_name, :last_name, :nickname, :address, :zip_code, :town, :country,
                    :email, :adress_nummer]

    attr_reader :kind, :changed_at, :changeset, :primary_roles, :primary_layer, :primary_group,
                :phone_number_private, :phone_number_mobile,
                *PERSON_ATTRS

    def initialize(person, kind, changed_at, changeset = {})
      @kind = kind
      @changed_at = changed_at
      @changeset = changeset
      store_attrs(person)
      store_values(person)
    end

    def to_s
      "#{first_name} #{last_name} / #{nickname}"
    end

    private

    def store_attrs(person)
      PERSON_ATTRS.each do |attr|
        instance_variable_set("@#{attr}", person.send(attr))
      end
    end

    def store_values(person)
      @primary_roles = fetch_primary_roles(person)
      @primary_layer = fetch_primary_layer(person).to_s
      @primary_group = person.primary_group.to_s
      @phone_number_private = fetch_phone_number(person, 'Privat')
      @phone_number_mobile = fetch_phone_number(person, 'Mobil')
    end

    def fetch_primary_roles(person)
      person.roles.select { |r| r.group_id = person.primary_group_id }.collect(&:to_s)
    end

    def fetch_primary_layer(person)
      person.primary_group.try(:layer_group).to_s
    end

    def fetch_phone_number(person, label)
      person.phone_numbers.find { |n| n.label == label }.try(:number)
    end

  end
end
