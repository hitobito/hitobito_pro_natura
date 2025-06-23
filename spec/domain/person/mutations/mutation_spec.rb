# encoding: utf-8

#  Copyright (c) 2016, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require 'spec_helper'

describe Person::Mutations::Mutation do

  let(:group) { groups(:kyburg) }
  let(:person) { Fabricate(Group::JugendgruppeGremium::Member.name, group: group).person }

  subject { Person::Mutations::Mutation.new(person, :created, Time.zone.now, {}, 1.month.ago) }

  it 'resolves phone number' do
    person.phone_numbers.create!(number: '+41 79 000 00 00', label: 'Privat')
    expect(subject.phone_number_private).to eq('+41 79 000 00 00')
    expect(subject.phone_number_mobile).to be_nil
  end

  it 'resolves primary group' do
    expect(subject.primary_group).to eq(group.to_s)
  end

  it 'resolves primary layer' do
    expect(subject.primary_layer).to eq(groups(:thun).to_s)
  end

  it 'resolves roles' do
    expect(subject.primary_roles).to eq(['Mitglied'])
  end

  it 'resolves role changes' do
    expect(subject.role_changes).to eq(true)
  end

end
