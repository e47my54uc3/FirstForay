module Api
  module V1
    class UsersController < ApiController
      #http_basic_authenticate_with name: "admin", password: "secret"
      respond_to :json

      def new
        @user = User.new
        respond_with @user
      end

      def create
        @user = User.new(params[:user])
        #@newsfeed=Newsfeed.new
        #@newsfeed.log(NEWSFEED_STREAM_VERBS[:new_user],'new_user',@user.reecher_id,@user.class.to_s,"#{@user.first_name} #{@user.last_name}",nil,nil,nil,nil,nil,0)
        if @user.save #&& @newsfeed.save #&& @user.create_reecher_node
          respond_to do |format|
            format.json { render :json => "Registration Successful" }  # note, no :location or :status options
          end
        else
          respond_to do |format|
            format.json { render :json => @user.errors.full_messages }  # note, no :location or :status options
          end
        end
      end

      def show
        @user=current_user
        respond_with @user
      end

      def showconnections
        @user = User.find_by_reecher_id(params[:reecher_id])
        @all_connections=@user.friendship
        respond_with @all_connections
      end

private

    end
  end
end

