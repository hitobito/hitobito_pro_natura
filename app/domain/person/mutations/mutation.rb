#  Copyright (c) 2016 Pro Natura Schweiz. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

module Person::Mutations
  class Mutation
    PERSON_ATTRS = [:id, :first_name, :last_name, :nickname, :birthday, :address, :zip_code, :town, :country,
      :email, :adress_nummer]

    attr_reader :kind, :changed_at, :changeset,
      :primary_roles, :primary_layer, :primary_group, :role_changes,
      :phone_number_private, :phone_number_mobile,
      *PERSON_ATTRS

    def initialize(version, person = version.main)
      @kind = identify_kind(version)
      @changed_at = version.created_at
      @changeset = version.changeset
      @role_changes = version.item_type == Role.sti_name

      store_attrs(person)
      store_phone_numbers(person)
      (kind == :deleted) ? store_last_group_info(person) : store_primary_group_info(person)
    end

    def to_s
      "#{first_name} #{last_name} / #{nickname}"
    end

    private

    def identify_kind(version)
      if version.event == "delete"
        :deleted
      elsif version.event == "create" && version.item_type == Person.sti_name
        :created
      else
        :updated
      end
    end

    def store_attrs(person)
      PERSON_ATTRS.each do |attr|
        instance_variable_set(:"@#{attr}", person.send(attr))
      end
    end

    def store_phone_numbers(person)
      @phone_number_private = fetch_phone_number(person, "Privat")
      @phone_number_mobile = fetch_phone_number(person, "Mobil")
    end

    def store_primary_group_info(person)
      @primary_roles = person.roles.select { |r| r.group_id == person.primary_group_id }.collect(&:to_s)
      @primary_layer = person.primary_group&.layer_group.to_s
      @primary_group = person.primary_group.to_s
    end

    def store_last_group_info(person)
      last_role = person.roles.with_inactive.order("end_on DESC").first
      if last_role
        @primary_roles = [last_role.to_s]
        @primary_layer = last_role.group&.layer_group.to_s
        @primary_group = last_role.group.to_s
      else
        @primary_roles = []
      end
    end

    def fetch_phone_number(person, label)
      person.phone_numbers.find { |n| n.label == label }&.number
    end
  end
end
