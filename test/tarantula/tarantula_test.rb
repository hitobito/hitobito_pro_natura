# encoding: utf-8

#  Copyright (c) 2012-2015, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require 'test_helper'
require 'relevance/tarantula'
require 'tarantula/tarantula_config'

class TarantulaTest < ActionDispatch::IntegrationTest
  # Load enough test data to ensure that there's a link to every page in your
  # application. Doing so allows Tarantula to follow those links and crawl
  # every page.  For many applications, you can load a decent data set by
  # loading all fixtures.

  reset_fixture_path File.expand_path('../../../spec/fixtures', __FILE__)

  include TarantulaConfig

  def test_tarantula_as_pl_jugend
    crawl_as(people(:pl_jugend))
  end

  def test_tarantula_as_thun_leiter
    crawl_as(people(:thun_leader))
  end

  def test_tarantula_as_mitglied
    crawl_as(people(:thun_member))
  end

  private

  def configure_urls_with_hitobito_pro_natura(t, person)
    configure_urls_without_hitobito_pro_natura(t, person)

    # Wagon specific urls configuration here
  end
  alias_method_chain :configure_urls, :hitobito_pro_natura

end
