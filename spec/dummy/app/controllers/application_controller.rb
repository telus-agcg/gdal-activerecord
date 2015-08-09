class ApplicationController < ActionController::Base
  include AgrianAction::ControllerSupport

  protect_from_forgery with: :exception

  def current_user
    User.current
  end
end
