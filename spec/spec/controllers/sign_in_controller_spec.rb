require 'rails_helper'

describe SignInController, type: :controller do
  describe '#create' do
    ActiveResource::HttpMock.respond_to(false) do |mock|
      mock.post '/core/sessions.json',
        { 'Content-Type' => 'application/json', 'Authorization' => 'AUTH-TOKEN 12345' },
        { session: { user: { first_name: 'Darrel' } }, auth_token: '12345' }.to_json,
        201
    end

    it 'sets @current_user to the logged in user' do
      post :create, user: { email: 'tester@test.com', passowrd: 'meow' }
      expect(assigns(:current_user)).to be_a User
    end
  end
end
