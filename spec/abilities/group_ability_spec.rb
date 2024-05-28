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

  context :group_and_below_read do
    describe 'Mitglied Jugendgremium' do
      let(:group) { groups(:kyburg) }
      let(:role_name) { Group::JugendgruppeGremium::Member }

      it 'may view details of himself' do
        is_expected.to be_able_to(:show_full, role.person.reload)
      end

      it 'may update himself' do
        is_expected.to be_able_to(:update, role.person.reload)
        is_expected.to be_able_to(:update_email, role.person)
      end

      it 'may not update his role' do
        is_expected.not_to be_able_to(:update, role)
      end

      it 'may not create other users' do
        is_expected.not_to be_able_to(:create, Person)
      end

      it 'may not view others in same group' do
        other = Fabricate(role_name.name, group: group)
        is_expected.not_to be_able_to(:show, other.person.reload)
      end

      it 'may not view details of others in same group' do
        other = Fabricate(role_name.name, group: group)
        is_expected.not_to be_able_to(:show_details, other.person.reload)
      end

      it 'may not view full of others in same group' do
        other = Fabricate(role_name.name, group: group)
        is_expected.not_to be_able_to(:show_full, other.person.reload)
      end

      it 'may not view public role in same layer' do
        other = Fabricate(role_name.name, group: group)
        is_expected.not_to be_able_to(:show, other.person.reload)
      end

      it 'may not index same group' do
        is_expected.not_to be_able_to(:index_people, group)
        is_expected.not_to be_able_to(:index_local_people, group)
        is_expected.not_to be_able_to(:index_full_people, group)
      end

      it 'may not create households' do
        is_expected.to_not be_able_to(:create_households, Person)
      end
    end
  end
end
