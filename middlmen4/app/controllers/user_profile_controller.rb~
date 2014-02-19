class UserProfileController < ApplicationController
  before_filter :get_user

  def index
    redirect_to login_user_path if current_user.nil?
    @profile = @user.user_profile
  end

  # POST /:username/profile/:beamer_id
  def update
  end

end
