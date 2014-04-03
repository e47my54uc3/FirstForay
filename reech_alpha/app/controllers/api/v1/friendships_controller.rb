module Api
	module V1
		class FriendshipsController < ApiController
		before_filter :restrict_access
		respond_to :json

			def index
				user = User.find_by_reecher_id(params[:user_id])
				@friends = user.friends
				@friends_list = []
				@friends.select {|f| @friends_list << {:name => f.full_name, :email => f.email} } if @friends.size > 0
				logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ @friends_list }"
				render :json => @friends_list
			end

		end
	end   
end