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
          image_url = userProfile.picture_url 
          else 
          image_url =  userProfile.profile_pic_path 
          end
          userProfile.picture_file_name != nil ? userProfile[:image_url] =  userProfile.picture_url : userProfile[:image_url] = nil
          @friends_list << {:name => user.first_name + " " + user.last_name,:email=> user.email,"reecherId" =>user.reecher_id,:location=>userProfile.location ,:image_url =>image_url,:associated_group_ids=>user_group_ids }
          end 
				end
				groups=Group::reecher_personal_groups params[:user_id]
				
				#@friends_list << {:categorie =>categories}
				### SEND notification
=begin				
				if !params[:audien_details].nil? 
                  if params[:audien_details].has_key?("emails")             
                    if !params[:audien_details][:emails].empty?
                      audien_reecher_ids = []
                      params[:audien_details][:emails].each do |email|
                        user = User.find_by_email(email)
                        # If audien is a reecher store his reedher_id in question record
                        # Else send an Invitation mail to the audien
                        if user.present?
                          audien_reecher_ids << user.reecher_id
                        else
                          begin
                            UserInvitationWithContact.invite_friend(email, params[:user_id]).deliver
                          rescue Exception => e
                          logger.error e.backtrace.join("\n")
                          end
                          
                        end 
                      end 
                      #@question.audien_user_ids = audien_reecher_ids if audien_reecher_ids.size > 0
                    end 
                 end
              # If the audien is not a reecher and have contact number then send an SMS
              if params[:audien_details].has_key?("phone_numbers")     
                if !params[:audien_details][:phone_numbers].empty? 
                  client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
                  params[:audien_details][:phone_numbers].each do |number|                  
                    sms = client.account.sms.messages.create(
                        from: TWILIO_CONFIG['from'],
                        to: number,
                        body: "Hey! Got a minute? Your friend #{user.first_name} #{user.last_name} needs your help on Reech. Visit http://reechout.co to download the app and help them out. Invite code: #{refral_code}"
                    )
                    logger.debug ">>>>>>>>>Sending sms to #{number} with text #{sms.body}"
          
                  end 
                end 
             end
             
             if params[:audien_details].has_key?("reecher_ids") 
              post_quest_to_frnd =[]
              if !params[:audien_details][:reecher_ids].empty? 
                 params[:audien_details][:reecher_ids].each do |reech_id|
                  begin
                    UserInvitationWithContact.invite_friend(user.email, params[:user_id]).deliver
                  rescue Exception => e
                    logger.error e.backtrace.join("\n")
                  end
                 
                end 
                
              end
            end 
        end  
        # End of send notification
        
=end				
				
				
				logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ @friends_list }"
				msg = {:status => 200, :friends_list => @friends_list,:groups =>groups }
				render :json => msg
			end
      #END 
      
      
		end
	end   
end