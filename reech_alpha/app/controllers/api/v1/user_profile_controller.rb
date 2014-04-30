module Api
	module V1
		class UserProfileController < ApiController
		before_filter :restrict_access, :except => [:forget_password]	
		respond_to :json
				
				def index
					@user = User.find_by_reecher_id(params[:user_id])
					if @user.nil?
						msg = {:status => 400, :message => "User does not exist."}
						render :json => msg
					else
						#@profile = current_user.user_profile
						#@badge = current_user.badges
						@profile = @user.user_profile.attributes
						@profile[:hi5] = @user.user_profile.votes.size
						@user.user_profile.picture_file_name != nil ? @profile[:image_url] = "http://#{request.host_with_port}" + @user.user_profile.picture_url : @profile[:image_url] = nil
						msg = {:status => 200, :user => @user, :profile => @profile }
						render :json => msg
					end
				end

				# POST /update_profile
				def update
					@user = User.find_by_reecher_id(params[:user_id])
					@user.first_name = params[:first_name]
					@user.last_name = params[:last_name]
					
					@profile = @user.user_profile
					@profile.location = params[:location]
					@profile.bio = params[:about]
					if !params[:profile_image].blank? 
						data = StringIO.new(Base64.decode64(params[:profile_image]))
						@profile.picture = data
					end	

					if @user.save && @profile.save
						@profile_hash = @user.user_profile.attributes
						@profile.picture_file_name != nil ? @profile_hash[:image_url] = "http://#{request.host_with_port}" + @profile.picture_url : @profile_hash[:image_url] = nil
						msg = {:status => 200, :user => @user, :profile => @profile_hash }
					else
						msg = {:status => 400, :message => @user.errors + @profile.errors}
					end	
					render :json => msg
				end

				def changepass
				 @user = User.find_by_reecher_id(params[:user_id])
				 api_key = ApiKey.find_by_access_token_and_user_id(params[:api_key], params[:user_id])
				 old_pwd_flag = params[:old_password].blank? ? false : @user.valid_password?(params[:old_password])
				 pwd_flag = params[:new_password] == params[:confirm_password] ? true : false
				 @pass = params[:new_password]

					if pwd_flag && old_pwd_flag
							if @pass.length < 6
								msg = {:status => 400, :message => "password must be at least 6 characters"}
								logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"
								render :json => msg
							else
								@user.password = @pass
								@user.password_confirmation = @pass
								@user.save(:validate => false)
								api_key.destroy
								current_user_session.destroy if !current_user_session.nil?
								msg = {:status => 200, :message => "Your password has been changed please login again"}
								logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"
								render :json => msg
							end
					else
						message = old_pwd_flag ? "Password and confirm Password does not match." : "Invalid old password."
						msg = {:status => 400, :message => message}
						logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"
						render :json => msg   # note, no :location or :status options
					end
				end

				def forget_password
					@user = User.find_by_email(params[:email])
					if !@user.nil?
						@user.deliver_password_reset_instructions!
						msg = {:status => 200, :message => "Password sent to your email"}
						logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"
						render :json => msg
					else
						msg = {:status => 400, :message => "Given Email not found"}
						logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"
						render :json => msg
					end	
				end	

				def showconnections
						@user=User.find_by_reecher_id(params[:user_id])
						@all_connections = @user.friends.find(:all, :select => "first_name, last_name, email,friend_reecher_id")
						if !@all_connections.nil?
							msg = {:status=> 200, :message => @all_connections}
							render :json => msg
						else
							msg = {:status=> 400, :message => "No connections"}
							render :json => msg
						end
				end

				def profile_dash_board
					@user = User.find_by_reecher_id(params[:user_id])
					@user.present? ? msg = {:status => 200, :questions => @user.questions.size, :solutions => @user.solutions.size, :connections => @user.friendships.size} : msg = {:status => 400, :message => "User doesn't exist"}
					render :json => msg
				end	

				def profile_hi5
					voting_user = User.find_by_reecher_id(params[:user_id])
					votable_user = User.find_by_reecher_id(params[:voter_id])
					votable_user.user_profile.liked_by(voting_user)
					msg = {:status => 200 , :message => "Success"}
					render :json => msg
				end	

				def add_contact
				 @user = User.find_by_reecher_id(params[:user_id])
						if !params[:contact_details].nil?

							if !params[:contact_details][:email].nil?
								#params[:audien_details][:emails].each do |email|
									UserMailer.send_invitation_email_for_new_contact(params[:contact_details][:email], @user).deliver
							#	end
                            msg = {:status => 200, :message => "Email sent to the contact."}
							end	

							if !params[:contact_details][:phone_number].nil?
								client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
								#params[:contact_details][:phone_numbers].each do |number|
									sms = client.account.sms.messages.create(
        							from: TWILIO_CONFIG['from'],
        							to: params[:contact_details][:phone_number],
        							body: "your friend #{@user.first_name} #{@user.last_name} needs to add you as a contact on Reech."
      						)
								#end
                                msg = {:status => 200, :message => "SMS sent to the contact."}
							end	
							
							}
							render :json => msg
            else
              msg = {:status => 400, :message => "Failed to send Email/SMS."}
							render :json => msg
						end	
				end	

		end
	end
end

