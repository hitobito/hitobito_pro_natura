#  Copyright (c) 2024, Dachverband Schweizer Jugendparlamente. This file is part of
#  hitobito_dsj and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_dsj.

require "spec_helper"

describe SearchStrategies::PersonSearch do
  before do
    people(:thun_leader).update!(adress_nummer: 12345, language: "de")
  end

  describe "#search_fulltext" do
    let(:user) { people(:pl_jugend) }

    it "finds accessible person by adress nummer" do
      result = search_class(people(:thun_leader).adress_nummer.to_s).search_fulltext
      expect(result).to include(people(:thun_leader))
    end
  end

  def search_class(term = nil, page = nil)
    described_class.new(user, term, page)
  end
end
