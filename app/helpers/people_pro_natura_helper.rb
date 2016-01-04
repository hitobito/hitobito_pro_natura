# encoding: utf-8

#  Copyright (c) 2012-2016, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

module PeopleProNaturaHelper

  def person_languages
    Person::LANGUAGES.collect {|l| [l, t_person_language(l)]}
  end

  def format_person_language(person)
    t_person_language(person.language)
  end

  private
  def t_person_language(language)
    return unless language.present?
    prefix = 'people.language.'
    t(prefix + language.downcase)
  end
end
