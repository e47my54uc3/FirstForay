module Api
  module V1
    class UserSessionsController < ApplicationController
    respond_to :json

      def new
        if !current_user.nil?
          respond_with "Already logged in"
        else
          @user_session = UserSession.new
        end
      end
      
      def create
        if !current_user.nil?
          respond_to do |format|
            format.json { render :json => "Already logged in" }  # note, no :location or :status options
          end
        else
          @user_session = UserSession.new(params[:user_session])
          if @user_session.save
            respond_to do |format|
              format.json { render :json => "Login Successful" }  # note, no :location or :status options
            end
          else
            respond_to do |format|
              format.json { render :json => "Login Failed" }  # note, no :location or :status options
            end
          end
        end
      end

      def show
        @user=current_user
        respond_with @user
      end

      
      def destroy
        if current_user_session.nil?
          respond_with "Not Logged In"
        else
          current_user_session.destroy
          respond_with "Logout success"
        end
      end

    end
  end
end
