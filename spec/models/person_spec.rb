# encoding: utf-8

#  Copyright (c) 2012-2016, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require 'spec_helper'

describe Person do

  describe '#language' do
    it 'accepts values DE FR IT' do
      %w(DE FR IT).each do |value|
        person = Person.new(last_name: 'dummy', language: value)
        expect(person).to be_valid
      end
    end

    it 'accepts blank and nil values' do
      expect(Person.new(last_name: 'dummy')).to be_valid
      expect(Person.new(last_name: 'dummy', language: '')).to be_valid
    end

    it 'rejects any other value' do
      expect(Person.new(last_name: 'dummy', language: 'other')).not_to be_valid
    end
  end

end
