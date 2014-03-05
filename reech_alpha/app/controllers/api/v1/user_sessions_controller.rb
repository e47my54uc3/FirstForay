module Api
  module V1
    class UserSessionsController < ApplicationController
    respond_to :json

      def new
        if !current_user.nil?
          respond_to do |format|
            msg = { :status => "ok", :message => "Already logged in!"}
            format.json { render :json => msg }  # note, no :location or :status options
          end
        else
          @user_session = UserSession.new
        end
      end
      
      def create
        if !current_user.nil?
          respond_to do |format|
            msg = { :status => "ok", :message => "Already logged in!"}
            format.json { render :json => msg }  # note, no :location or :status options
          end
        else
          @user_session = UserSession.new(params[:user_session])
          if @user_session.save
            respond_to do |format|
              msg = { :status => "ok", :message => "Success!"}
              format.json { render :json => msg }  # note, no :location or :status options
            end
          else
            respond_to do |format|
              msg = { :status => "error", :message => "Failure!"}
              format.json { render :json => msg }  # note, no :location or :status options
            end
          end
        end
      end

      def show
        @user=current_user
        respond_to do |format|
          format.json { render :json => @user }  # note, no :location or :status options
        end
      end

      
      def destroy
        if current_user_session.nil?
          respond_to do |format|
            msg = { :status => "error", :message => "Not logged in!"}
            format.json { render :json => msg }  # note, no :location or :status options
          end
        else
          current_user_session.destroy
          respond_to do |format|
            msg = { :status => "ok", :message => "Success!"}
            format.json { render :json => msg }  # note, no :location or :status options
          end
        end
      end

    end
  end
end
