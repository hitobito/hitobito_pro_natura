#  Copyright (c) 2016 Pro Natura Schweiz. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

module Person::Mutations
  class Fetcher
    EXCLUDED_ROLES = [
      Group::JugendgruppePassive::Admin,
      Group::JugendgruppePassive::Member
    ].map(&:sti_name)

    attr_reader :since

    def initialize(since)
      @since = since
    end

    def fetch
      all_mutations.sort_by(&:changed_at)
    end

    def mutated_people
      people_with_roles
        .joins("INNER JOIN versions " \
              "ON versions.main_id = people.id AND versions.main_type = 'Person'")
        .where(versions: {created_at: since..})
        .group("people.id")
        .having(<<~SQL,
          MAX(COALESCE(roles.end_on, '9999-01-01')) > :today
        SQL
          today: Date.current)
    end

    def deleted_people
      people_with_roles
        .select("people.*, MAX(roles.end_on) AS deleted_at")
        .group("people.id")
        .having(<<~SQL,
          -- if the person has roles where end_on is NULL, we do not care about the real max(end_on)
          -- as it ignores rows with NULL value, so we use coalesce to set it to a date in the future
          MAX(COALESCE(roles.end_on, '9999-01-01')) BETWEEN :since AND :today
        SQL
          since: since.to_date,
          today: Date.current)
    end

    private

    def all_mutations
      mutated_people.includes(:roles, :phone_numbers, :primary_group).find_each.collect do |person|
        add_modified_person(person)
      end +
        deleted_people.includes(:phone_numbers).find_each.collect do |person|
          add_deleted_person(person)
        end
    end

    def people_with_roles
      Person
        .joins("INNER JOIN roles ON roles.person_id = people.id")
        .where.not(roles: {type: EXCLUDED_ROLES})
        .distinct
    end

    def add_modified_person(person)
      kind = identify_kind(person)
      version = PaperTrail::Version.where(main: person).order("created_at DESC").first
      Mutation.new(person, kind, version.created_at, version.changeset, since)
    end

    def add_deleted_person(person)
      changed_at = case person.deleted_at
      when Date then person.deleted_at.beginning_of_day
      when String then DateTime.parse(person.deleted_at).in_time_zone
      else person.deleted_at
      end
      Mutation.new(person, :deleted, changed_at)
    end

    def identify_kind(person)
      if person.created_at >= since
        :created
      else
        :updated
      end
    end
  end
end
