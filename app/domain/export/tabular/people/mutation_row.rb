# encoding: utf-8

#  Copyright (c) 2016 Pro Natura Schweiz. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.


module Export::Tabular::People
  class MutationRow < Export::Tabular::Row

    def primary_roles
      entry.primary_roles.collect(&:to_s).join(', ')
    end

    def changeset
      entry.changeset.collect do |attr, (before, after)|
        "#{Person.human_attribute_name(attr)}: #{before.inspect} -> #{after.inspect}"
      end.join(', ')
    end

    def kind
      I18n.t("export/tabular/people/mutations.kinds.#{entry.kind}")
    end

  end
end
