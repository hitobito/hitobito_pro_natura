# encoding: utf-8

#  Copyright (c) 2012-2016, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.


module PersonIndex; end

ThinkingSphinx::Index.define_partial :person do
  indexes adress_nummer, language
end
