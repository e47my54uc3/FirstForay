module Api
  module V1
    class AuthorizationsController < ApplicationController
    respond_to :json
    before_filter :require_user, :only => [:destroy]
    
    def index
      @auth = current_user.authorizations
      respond_with @auth
    end 

    def create
      omniauth = request.env['omniauth.auth'] #this is where you get all the data from your provider through omniauth
      @auth = Authorization.find_from_omniauth_data(omniauth)
    if current_user
      current_user.add_points(500) 
      current_user.authorizations.create(:provider => omniauth['provider'], :uid => omniauth['uid']) #Add an auth to existing user
      respond_with "Successfully added #{omniauth['provider']} authentication"
    elsif @auth
      UserSession.create(@auth.user, true) #User is present. Login the user with his social account
      respond_with "Welcome back #{omniauth['provider']} user"
    else
      @new_auth = Authorization.create_from_omniauth_data(omniauth, current_user) #Create a new user
      UserSession.create(@new_auth.user, true) #Log the authorizing user in.
      @new_auth.user.add_points(500)
      respond_with "Welcome #{omniauth['provider']} user. Account created"
    end
    
  end


  def failure
    respond_with "Authorization failed"
  end
  
  def blank
    respond_with "404 not found"
  end

  def destroy
    @authorization = current_user.authorizations.find(params[:id])
    @authorization.destroy
    respond_with "Deleted #{@authorization.provider} authentication"
  end


private

    def addednetwork
      return true;
    end

    def networklogin
      return true;
    end

    end
  end
end
