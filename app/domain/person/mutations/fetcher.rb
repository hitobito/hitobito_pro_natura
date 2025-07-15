#  Copyright (c) 2016 Pro Natura Schweiz. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

module Person::Mutations
  class Fetcher
    LEADER_ROLES = [
      Group::DachverbandGremium::Leader,
      Group::Jugendgruppe::Leader,
      Group::JugendgruppeGremium::Leader
    ].map(&:sti_name)

    attr_reader :since

    def initialize(since)
      @since = since
    end

    def mutations
      all_people = (people_with_roles + deleted_people).index_by(&:id)
      versions = fetch_versions(all_people.keys)

      mutations = versions.map do |version|
        Mutation.new(version, all_people[version.main_id], deleted_people.map(&:id).include?(version.main_id))
      end

      deleted_mutations = deleted_people.map do |person|
        Mutation.new(build_deleted_version(person), person, true)
      end

      (mutations + deleted_mutations).sort_by(&:changed_at)
    end

    private

    def build_deleted_version(person)
      PaperTrail::Version.new(
        main: person,
        created_at: person.deleted_at,
        event: :delete
      )
    end

    def fetch_versions(ids)
      PaperTrail::Version.where(main_type: Person.sti_name, main_id: ids, created_at: since..)
        .order(created_at: :desc)
    end

    def people_with_roles
      @people_with_roles ||= Person.joins(:roles_unscoped)
        .where(roles: {type: LEADER_ROLES})
        .where("roles.end_on IS NULL OR roles.end_on >= ?", since.to_date)
        .includes(:roles, :phone_numbers, :primary_group)
        .distinct
    end

    def deleted_people
      @deleted_people ||= people_with_roles
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
  end
end
