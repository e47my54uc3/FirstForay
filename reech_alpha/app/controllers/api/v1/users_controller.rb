module Api
  module V1
    class UsersController < ApplicationController
    respond_to :json
      #http_basic_authenticate_with name: "admin", password: "secret"
      def new
        @user = User.new
        respond_with @user
      end

      def create
        @user = User.new(params[:user])
        #@newsfeed=Newsfeed.new
        #@newsfeed.log(NEWSFEED_STREAM_VERBS[:new_user],'new_user',@user.reecher_id,@user.class.to_s,"#{@user.first_name} #{@user.last_name}",nil,nil,nil,nil,nil,0)
        if @user.save #&& @newsfeed.save #&& @user.create_reecher_node
          @api_key = ApiKey.create.access_token
             msg = {:status => 201, :api_key=>@api_key, :email=>@user.email, :user_id=>@user.reecher_id}
             render :json => msg  # note, no :location or :status options
        else
            msg = { :status => 401, :message => @user.errors.full_messages}
            render :json => msg  # note, no :location or :status option
        end
      end

      
      def show
        @user=current_user
        respond_to do |format|
          format.json { render :json => @user }  # note, no :location or :status options
        end
      end

    end
  end
end

