require 'rails_helper'

describe ApiController, type: :controller do
  controller do
    def index
      render nothing: true
    end
  end

  it 'authorizes against core' do
    expect(subject).to receive(:authorize_against_core!)

    get :index
  end
end
