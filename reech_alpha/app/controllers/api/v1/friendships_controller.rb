module Api
	module V1
		class FriendshipsController < ApiController
		before_filter :restrict_access
		respond_to :json

			def index
				user = User.find_by_reecher_id(params[:user_id])
				@friends = user.friendships.where(:status => "accepted")
				@friends_list = []
				if @friends.size >0
  				@friends.each do |f| 
          user= User.find_by_reecher_id(f.friend_reecher_id)  
          group_ids = Group::get_friend_associated_groups params[:user_id] ,user.id
          user_group_ids =[]
          group_ids.each do |i|
            user_group_ids.push(i.values)
          end
          user_group_ids.flatten! 
          userProfile = user.user_profile if user
          
          if !userProfile.picture_file_name.blank?  
          image_url ="http://#{request.host_with_port}" + userProfile.picture_url 
          else 
          image_url =  userProfile.profile_pic_path 
          end
          userProfile.picture_file_name != nil ? userProfile[:image_url] = userProfile.picture_url : userProfile[:image_url] = nil
          @friends_list << {:name => user.first_name + " " + user.last_name,:email=> user.email,"reecherId" =>user.reecher_id,:location=>userProfile.location ,:image_url =>image_url,:associated_group_ids=>user_group_ids }
          end 
				end
				groups=Group::reecher_personal_groups params[:user_id]
				#@friends_list << {:categorie =>categories}
				
				logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ @friends_list }"
				msg = {:status => 200, :friends_list => @friends_list,:groups =>groups }
				render :json => msg
			end
      #END 
      
      
		end
	end   
end