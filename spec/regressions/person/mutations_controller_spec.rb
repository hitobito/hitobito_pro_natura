# encoding: utf-8

#  Copyright (c) 2016, Pro Natura. This file is part of
#  hitobito_pro_natura and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pro_natura.

require 'spec_helper'

describe Person::MutationsController, type: :controller do

  render_views

  before { sign_in(people(:pl_jugend)) }

  context 'GET index' do
    context '.html' do
      it 'renders view' do
        get :index, params: { group_id: groups(:root).id }
        is_expected.to render_template('index')
      end

      it 'is not allowed for non-root groups' do
        expect do
          get :index, params: { group_id: groups(:thun).id }
        end.to raise_error(CanCan::AccessDenied)
      end
    end

    context '.csv' do
      it 'render html view if since is missing' do
        get :index, params: { group_id: groups(:root).id }, format: :csv
        is_expected.to render_template('index')
        expect(flash.now[:alert]).to be_present
      end

      it 'render html view if since is not a valid date' do
        get :index, params: { group_id: groups(:root).id, since: '33.33.33' }, format: :csv
        is_expected.to render_template('index')
        expect(flash.now[:alert]).to be_present
      end

      it 'renders csv' do
        get :index, params: { group_id: groups(:root).id, since: '1.1.2016' }, format: :csv
        expect(response.body).to match(/Mutationsart/)
      end
    end
  end

end
