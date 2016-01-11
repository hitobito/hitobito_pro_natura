# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe PeopleProNaturaHelper do

  context 'person language' do

    let(:person) { people(:thun_leader) }
    let(:languages) { helper.person_languages }

    it 'includes deutsch, französisch, italienisch' do
      expect(languages.size).to eq 3
      expect(languages).to include(['DE', 'deutsch'])
      expect(languages).to include(['IT', 'italienisch'])
      expect(languages).to include(['FR', 'französisch'])
    end

    it 'formats persons language' do
      person.language = 'FR'
      expect(helper.format_person_language(person)).to eq 'französisch'
    end

    it 'nothing if no language set' do
      expect(helper.format_person_language(person)).to eq nil
    end

  end

end
