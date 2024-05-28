# frozen_string_literal: true

#  Copyright (c) 2024-2024, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require 'spec_helper'

describe PersonAbility do
  let(:role) { Fabricate(role_name.name, group: group) }
  let(:ability) { Ability.new(role.person.reload) }

  subject { ability }

  context 'impersonation' do
    describe 'PlJugend' do
      let(:role_name) { Group::Dachverband::PlJugend }
      let(:group) { groups(:root) }

      it 'may impersonate users' do
        is_expected.to be_able_to(:impersonate_user, people(:thun_member))
      end
    end
  end
end
