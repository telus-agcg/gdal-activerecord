require 'rails_helper'

describe CoreResourcesController, type: :controller do
  describe '#index' do
    context 'unauthorized' do
      it 'returns a 401' do
        get :index, format: :json
        expect(response.status).to eq 401
        expect(response.body).to match 'errors'
      end
    end

    context 'authorized' do
      it 'returns a 200 with' do
        request.env['HTTP_AUTHORIZATION'] = 'AUTH-TOKEN 12345'
        expect(subject).to receive(:authorize_against_core!).and_call_original
        get :index, {},  'HTTP_AUTHORIZATION' => 'AUTH-TOKEN 12345'

        expect(response.status).to eq 200
      end
    end
  end
end
