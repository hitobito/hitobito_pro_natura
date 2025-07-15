# frozen_string_literal: true

#  Copyright (c) 2025, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

class Export::MutationsExportJob < Export::ExportBaseJob
  self.parameters = PARAMETERS + [:since]

  def initialize(format, user_id, since, options)
    super(format, user_id, options)
    @since = since
  end

  private

  def data
    Export::Tabular::People::Mutations.csv(fetcher.mutations)
  end

  def fetcher
    @fetcher ||= Person::Mutations::Fetcher.new(@since)
  end
end
