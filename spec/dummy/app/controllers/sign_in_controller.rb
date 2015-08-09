class SignInController < ApplicationController
  def create
    @session = Session.create(user: params[:user])

    if @session
      @current_user = User.current = @session.user

      respond_to do |format|
        format.html do
          flash[:info] = 'Good job.'
          redirect_to root_path
        end
      end
    else
      invalid_email_or_password
    end
  end
end
