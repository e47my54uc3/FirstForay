class UserSessionsController < ApplicationController
	def new
    flash[:notice] = "Bad Request.You are already logged in!" if !current_user.nil?
    redirect_to root_url if !current_user.nil?
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_to root_url
    else
      flash[:notice] = "Login unsuccessful! Please type correct email and password"
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "You have logged out!"
    redirect_to root_url
  end
end
