class ApiController < ActionController::API
  include AgrianAction::ControllerSupport

  before_action :authorize_against_core!
end
