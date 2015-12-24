# encoding: utf-8

#  Copyright (c) 2012-2015, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

namespace :app do
  namespace :license do
    task :config do
      @licenser = Licenser.new('hitobito_pro_natura',
                               'Pro Natura',
                               'https://github.com/hitobito/hitobito_pro_natura')
    end
  end
end
