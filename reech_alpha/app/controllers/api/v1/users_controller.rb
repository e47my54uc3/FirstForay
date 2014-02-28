module Api
  module V1
    class UsersController < ApplicationController
      #http_basic_authenticate_with name: "admin", password: "secret"
      before_filter :restrict_access
    
      respond_to :json

      def index
        respond_with User.find(:all)
      end

      def new
        respond_with User.new
      end

      def create
        respond_with User.new(params[:user])
      end

      def show
        respond_with User.find(params[:id])
      end

      def showconnections
        respond_with User.find_by_reecher_id(params[:reecher_id])
      end

private

    def restrict_access
      authenticate_or_request_with_http_token do |token, options|
      ApiKey.exists?(access_token: token)
      end
    end

    end
  end
end

