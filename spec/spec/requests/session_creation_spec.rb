require 'rails_helper'

describe 'Session creation', type: :request do
  it 'creates a new session' do
    post '/core/sign_in',  user: { email: 'tester@test.com', passowrd: 'meow' }

    expect(response).to redirect_to(root_path)
  end
end
