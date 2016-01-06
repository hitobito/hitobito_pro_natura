# encoding: utf-8

#  Copyright (c) 2016, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require 'spec_helper'

describe GroupAbility do

  let(:role) { Fabricate(role_name.name, group: group) }
  let(:ability) { Ability.new(role.person.reload) }

  subject { ability }

  context :index_mutations do

    context 'pl jugend' do
      let(:group) { groups(:root) }
      let(:role_name) { Group::Dachverband::PlJugend }

      it 'is allowed for root group' do
        is_expected.to be_able_to(:index_mutations, group)
      end

      it 'is not allowed for sektion' do
        is_expected.not_to be_able_to(:index_mutations, groups(:be))
      end

    end

    context 'jugendgruppe admin' do
      let(:group) { groups(:thun) }
      let(:role_name) { Group::Jugendgruppe::Admin }

      it 'is not allowed for root group' do
        is_expected.not_to be_able_to(:index_mutations, groups(:root))
      end

      it 'is not allowed for jugendgruppe' do
        is_expected.not_to be_able_to(:index_mutations, group)
      end
    end

  end

end
