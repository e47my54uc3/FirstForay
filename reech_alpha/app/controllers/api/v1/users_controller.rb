module Api
	module V1
		class UsersController < ApplicationController
		respond_to :json ,:except =>[:send_apns_notification,:send_gcm_notification,:validate_referral_code]
			#http_basic_authenticate_with name: "admin", password: "secret"
			def new
				@user = User.new
				respond_with @user
			end

			def create
				if !params.blank?
					if params[:provider] == "standard"
					  
					  user = User.find_by_email(params[:user_details][:email])					  
						if user.nil?
								@user = User.new(params[:user_details])
								@user.password_confirmation = params[:user_details][:password]
								if @user.save
									if !params[:profile_image].blank? 
										data = StringIO.new(Base64.decode64(params[:profile_image]))
										@user.user_profile.picture = data
										@user.user_profile.save
									end
	  							@user.add_points(500)
	  							@api_key = ApiKey.create(:user_id => @user.reecher_id).access_token
									create_device_for_user(params[:device_token], params[:platform], @user.reecher_id)
									msg = {:status => 201, :message => "Success",:api_key=>@api_key, :user_id=>@user.reecher_id,:email =>@user.email}
									logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
									render :json => msg  # note, no :location or :status options
								else
									msg = { :status => 401, :message => @user.errors.full_messages}
									logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
									render :json => msg  # note, no :location or :status option
								end
						else
						   #@api_key = ApiKey.create(:user_id => user.reecher_id).access_token
							 #msg = { :status => 401, :message => "Email Already exists",:api_key=>@api_key, :user_id=>user.reecher_id,:email =>user.email}
							 msg = { :status => 401, :message => "Email Already exists"}
							 logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
							 render :json => msg
						end   
					elsif params[:provider] == "facebook"
						fb_user = User.find_by_fb_uid(params[:user_details][:uid])
						@graph = Koala::Facebook::API.new(params[:user_details][:access_token])
						fb_user_profile_pic_path = @graph.get_picture(params[:user_details][:uid])
						@profile = @graph.get_object("me")
						@fb_friends = @graph.get_connections("me", "friends")
            if fb_user.nil?              
							@user = User.new()
							@user.first_name = @profile["first_name"]
							@user.last_name = @profile["last_name"]
							@user.email = @profile["email"]
							@user.fb_token = params[:user_details][:access_token]
							@user.fb_uid = params[:user_details][:uid]
  							if @user.save(:validate => false)		
  							  @user.user_profile.picture_from_url(fb_user_profile_pic_path.to_s)
  							  @user.user_profile.save
  							  #@user.user_profile.build
  							 #fb_user_profile_pic  = @user.create_user_profile(:profile_pic_path => fb_user_profile_pic_path)
  								#puts "1123213#{params[:device_token]}----#{params[:platform]}"
  								create_device_for_user(params[:device_token], params[:platform], @user.reecher_id)
                	make_friendship(@fb_friends,@user,params[:device_token]) if @fb_friends.size > 0
  								create_session_for_fb_user(@user)
  								Authorization.create(:user_id => @user.id, :uid => params[:user_details][:uid], :provider => params[:provider])
  								@user.add_points(500)
  								@api_key = ApiKey.create(:user_id => @user.reecher_id).access_token
  								msg = {:status => 201, :api_key=>@api_key, :user_id=>@user.reecher_id,:email=>@user.email}
  								logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
  								render :json => msg
  							end 
						else
						  make_friendship(@fb_friends,fb_user,params[:device_token]) if @fb_friends.size > 0
              create_device_for_user(params[:device_token], params[:platform], fb_user.reecher_id)
  					  create_session_for_fb_user(fb_user)
							@api_key = ApiKey.create(:user_id => fb_user.reecher_id).access_token
							msg = {:status => 201, :api_key=>@api_key, :user_id=>fb_user.reecher_id,:email=>fb_user.email}
							logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
							render :json => msg
						end 
					end  
				else
					msg = { :status => 401, :message => "Failure!"}
					logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
					render :json => msg
				end      

			end

			
			def show
				@user=current_user
				respond_to do |format|
					format.json { render :json => @user }  # note, no :location or :status options
				end
			end

			def create_device_for_user(device_token, platform, reecher_id)
			 	if !device_token.blank? && !platform.blank?
				  existing_device = Device.where(:device_token => device_token, :platform => platform, :reecher_id => reecher_id)
					puts "existing_device"
					if !existing_device.present?
						device = Device.new()
						device.device_token = device_token
						device.platform = platform
						device.reecher_id = reecher_id
						device.save
					end  
				end  
			end
				
			def create_session_for_fb_user(user)
				user.reset_persistence_token!
				UserSession.create(user, true)
			end  

			def make_friendship(fb_friends, fb_user,device_token)
=begin			 
			  puts "fb_friends=#{fb_friends}"
			  puts "fb_user=#{fb_user}"
			  puts "device_token=#{device_token}"
				 n1 = APNS::Notification.new(device_token, 'Hello iPhone!' )
         n2 = APNS::Notification.new(device_token, :alert => 'Hello iPhone!', :badge => 1, :sound => 'default')
         APNS.send_notifications([n2])
=end        
         #APNS.send_notification(device_token, 'Hello iPhone!' )
        fb_friends_list_uids = []
        fb_friends.select {|fu| fb_friends_list_uids << fu["id"] }
        fb_friends_list_uids.each do |f|
         fb_user_existed = User.find_by_fb_uid(f)
					if !fb_user_existed.blank?
						if Friendship.request(fb_user_existed, fb_user)
							Friendship.accept(fb_user_existed, fb_user)
						end  
					end 
				end  
			 end   
        
      
    def send_apns_notification 
      n1= APNS::Notification.new(params[:device_token], :alert => params[:message], :badge => 1, :sound => 'default')
      APNS.send_notifications([n1])
      
       msg = { :status => 200, :message => params[:message]}
       render :json =>msg 
    end 
  
=begin    
    def send_gcm_notification  
     puts "Device token===#{params[:device_token]}" 
     destination= params[:device_token]
     data1 = {:key => "Hello"}
    # must be an hash with all values you want inside you notification
     options1 = {:collapse_key => "placar_score_global", :time_to_live => 3600, :delay_while_idle => false}
    # options for the notification
     #n1 = GCM.Notification(destination, data1, options1)
    #data = {:alert => "Hello Android!!!" } 
    # GCM.send_notification( destination,{"key" =>"HELLO WORLD"} )
      GCM.send_push_as_plain_text
      GCM.send_notification( destination,data1,options1 )
     # msg = { :status => 401, :message => "success"}
     # render :json =>msg
    end
=end    
     # Method Send reech requests
      def send_reech_request
      user = User.find_by_reecher_id(params[:user_id])
      if !user.blank?
        if !params[:audien_details][:email_ids].blank?
          params[:audien_details][:email_ids].each do |email|
            SendReechRequest.create(:user_id =>params[:user_id],:type=>params[:type],:contact_details=>params[:email])
              begin
                 UserMailer.send_reech_friend_request(email, user.full_name).deliver
              rescue Exception => e
                 logger.error e.backtrace.join("\n")
              end
          
          end
        end
        if !params[:audien_details][:phone_numbers].blank?
           client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
           params[:audien_details][:phone_numbers].each do |phone|
           SendReechRequest.create(:user_id =>params[:user_id],:type=>params[:type],:contact_details=>params[:phone])
=begin          
           sms = client.account.sms.messages.create(
                      from: TWILIO_CONFIG['from'],
                      to: phone,
                      body: "your friend #{user.first_name} #{user.last_name}  want to send you a friend request from Reech."
                  )
                  logger.debug ">>>>>>>>>Sending sms to #{phone} with text #{sms.body}"
=end
          end
        end
      end
      msg = { :status => 200, :message => "success"}
      render :json =>msg 
     end
  
    def remove_connections
        my_connection = Friendship.where("reecher_id=? && friend_reecher_id =? ", params[:user_id],params[:friend_id]).first
        friend_connection = Friendship.where("reecher_id=? && friend_reecher_id =? ", params[:friend_id],params[:user_id]).first
        my_connection.destroy unless  my_connection.blank?
        friend_connection.destroy unless  friend_connection.blank?
        msg = {:status => 200, :messgae => "User is removed from your connection" }
        render :json => msg  
    end
    
    def validate_referral_code
      
      current_date_time =Time.now
      referral_code = params[:referral_code]
      user_ref =InviteUser.where("referral_code = ? AND token_validity_time >= ?", params[:referral_code] ,current_date_time)
      
      if !user_ref.blank?
        link_question = LinkedQuestion.find(user_ref[0][:linked_question_id]) 
      msg = {:status => 200, :is_valid => true,:question_id=>link_question.question_id }
      else
      msg = {:status => 200, :is_valid => false }
      end 
      render :json => msg 
      
    end
      
#End of Class User Controller class
  		end
	end
end

