module Api
	module V1
		class FriendshipsController < ApiController
		before_filter :restrict_access
		respond_to :json

			def index
				user = User.find_by_reecher_id(params[:user_id])
				@friends = user.friendships.where(:status => "accepted")
				@friends_list = []
				@friends.select {|f| @friends_list << {:name => User.find_by_reecher_id(f.friend_reecher_id).full_name, :email => User.find_by_reecher_id(f.friend_reecher_id).email} } if @friends.size > 0
				logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ @friends_list }"
				msg = {:status => 200, :friends_list => @friends_list }
				render :json => msg
			end

		end
	end   
end