# encoding: utf-8

#  Copyright (c) 2012-2016, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require 'spec_helper'

describe Person do

  describe '#language' do
    it 'accepts values de fr it' do
      %w(de fr it).each do |value|
        person = Person.new(last_name: 'dummy', language: value)
        expect(person).to be_valid
      end
    end

    it 'does not accept blank value' do
      expect(Person.new(last_name: 'dummy', language: '')).to_not be_valid
    end

    it 'rejects any other value' do
      expect(Person.new(last_name: 'dummy', language: 'other')).not_to be_valid
    end
  end

end
