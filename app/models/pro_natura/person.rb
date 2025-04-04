#  Copyright (c) 2012-2016, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

module ProNatura::Person
  extend ActiveSupport::Concern

  included do
    Person::PUBLIC_ATTRS << :adress_nummer

    Person::SEARCHABLE_ATTRS << :adress_nummer << :language
  end
end
