module Api
	module V1
	  require "open-uri"
		class UserProfileController < ApiController
		before_filter :restrict_access, :except => [:forget_password]	
		respond_to :json
				
				def index
					@user = User.find_by_reecher_id(params[:user_id])
					
					if @user.nil?
						msg = {:status => 400, :message => "User does not exist."}
						render :json => msg
					else
						@profile = @user.user_profile.attributes
						@profile[:hi5] = @user.user_profile.votes_for.size
						@user.user_profile.picture_file_name != nil ? @profile[:image_url] =  @user.user_profile.picture_url : @profile[:image_url] = nil
						msg = {:status => 200, :user => @user, :profile => @profile ,:curio_points=> @user.points }
						render :json => msg
					end
				end

				# POST /update_profile
				def update
					
					@user = User.find_by_reecher_id(params[:user_id])
					@user.first_name = params[:first_name]
					@user.last_name = params[:last_name]
					
					@profile = @user.user_profile
					#@profile.update({:location => params[:location],:bio=>params[:about]})
					@profile.location = params[:location]
					@profile.bio = params[:about]
					if !params[:profile_image].blank? 
						data = StringIO.new(Base64.decode64(params[:profile_image]))
						@profile.picture = data
					end	
            
          if ((@user.fb_token !=nil) && (@user.fb_uid !=nil ))
            if @profile.save
            @profile_hash = @user.user_profile.attributes
            @profile.picture_file_name != nil ? @profile_hash[:image_url] =  @profile.picture_url : @profile_hash[:image_url] = nil
            msg = {:status => 200, :user => @user, :profile => @profile_hash }
					  else
					   msg = {:status => 400, :message => @user.errors}
					  end  
					else 
					   if @user.save &&  @profile.save
             @profile_hash = @user.user_profile.attributes
             @profile.picture_file_name != nil ? @profile_hash[:image_url] =  @profile.picture_url : @profile_hash[:image_url] = nil
             msg = {:status => 200, :user => @user, :profile => @profile_hash }
					   else
					   msg = {:status => 400, :message => @user.errors}
					   end  
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
								current_user_session.destroy if !current_user_session.n:reecheridil?
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
				  phone_number = filter_phone_number(params[:phone_number])
				  
					@user = User.find_by_phone_number(phone_number)
					puts "@user ==#{@user.inspect}"
					rand_str = (('A'..'Z').to_a + (0..9).to_a)
          pass_token = (0...8).map { |n| rand_str.sample }.join
          puts "pass_token== #{pass_token}"
          #@user.update_attributes(:password=> pass_token) unless @user.blank?
          @user.password = pass_token unless @user.blank?
          @user.save(:validate=> false)  unless @user.blank?

            
          
            
					if !@user.blank?           
              
              begin
              UserMailer.send_new_password_as_forgot_password(@user,pass_token).deliver    
               client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
                sms = client.account.sms.messages.create(
                          from: TWILIO_CONFIG['from'],
                          to: "+"+@user.phone_number,
                          body: "Username= #{@user.phone_number} and Temporary password= #{pass_token}"  
                          #body: "Dear #{@user.full_name},We are providing you a temporary password for login into application and later on you can reset it. Your Username= #{@user.phone_number} and Temporay password=#{pass_token}"
                      )
                   
              rescue Exception => e
              logger.error e.backtrace.join("\n")
              end
              logger.debug ">>>>>>>>>Sending sms to #{@user.phone_number} with text "
              msg = {:status => 200, :message => "Password sent to your phone number"}
              logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"
              render :json => msg
        else
            msg = {:status => 400, :message => "Given phone number not found"}
            logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"
            render :json => msg
          end 
          
         end
         
         
         
         
=begin					
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
=end					
			#	end	

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
					votable_user = User.find_by_reecher_id(params[:votable_user_id])
					votable_user.user_profile.liked_by(voting_user)
					msg = {:status => 200 , :message => "Success"}
					render :json => msg
				end	

				def add_contact
				 @user = User.find_by_reecher_id(params[:user_id])
						if !params[:contact_details].nil?

							if !params[:contact_details][:email].nil?
								UserMailer.send_invitation_email_for_new_contact(params[:contact_details][:email], @user).deliver
                 msg = {:status => 200, :message => "Email sent to the contact."}
							end	

							if !params[:contact_details][:phone_number].nil?
							  
							  
								client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
								begin
								sms = client.account.sms.messages.create(
        							from: TWILIO_CONFIG['from'],
        							to: "+"+params[:contact_details][:phone_number],
        							body: "your friend #{@user.first_name} #{@user.last_name} needs to add you as a contact on Reech."
      						)
      				  rescue Exception => e
                logger.error e.backtrace.join("\n")
               end	
      						
                msg = {:status => 200, :message => "SMS sent to the contact."}
							end	
							
							render :json => msg
            else
              msg = {:status => 400, :message => "Failed to send Email/SMS."}
              render :json => msg
            end
				end	
				
			# leader board
       def leader_board       
        final_leader = {}
        all_users= User.all
        user_details =[]
        current_user_hash =[]
        ### Today
        if !all_users.blank?
          all_users.each do |user|
            @user_profile = user.user_profile 
            profile_pic_path = (@user_profile.profile_pic_path).to_s
            if @user_profile.picture_file_name
             image_url =  @user_profile.picture_url      
            elsif @user_profile.profile_pic_path
              image_url = profile_pic_path
            else
              image_url = nil
            end
            questions=user.questions.where("created_at"=>(Time.now()).to_date)
            solution = user.solutions.where("created_at"=>(Time.now()).to_date)
            tot_question = questions.count
            tot_answer = solution.count
            tot_hi5 = user.user_profile.votes_for.size 
            tot_curios = user.points
           # position = ((0.3 * tot_curios) + (0.7*tot_hi5)).floor
           #(15%)Total curios + (20%)# of questions asked + (30%)# of solutions provided + (35%)# of hi5 received
             position =  ((0.15 * tot_curios) + (0.2*tot_question) + (0.3*tot_answer) + (0.35*tot_hi5)).floor
            user_details.push({"position" => position,"reecherid"=>user.reecher_id,"reechername"=>user.first_name+" "+ user.last_name,"reecherimage"=>image_url,"level"=>7,"scores"=> {"points_earned" => tot_curios ,"questions_asked" =>tot_question, "answers_given" =>tot_answer,"high_fives" =>tot_hi5}})
 
          end
         end
         
        current_user_hash =   user_details.select{ |hsh| hsh  if hsh.has_value? params[:user_id]}
        
        sort_user_detail = user_details.sort_by{ |h| h["position"]}.reverse
        
        sort_user_detail=sort_user_detail.take(5)
      
        final_leader[:today]= {"user_position"=>current_user_hash,"top_positions"=> sort_user_detail}
        final_leader[:week]= {"user_position"=>current_user_hash,"top_positions"=> sort_user_detail}
        final_leader[:month] = {"user_position"=>current_user_hash,"top_positions"=> sort_user_detail}
    
        ###############################################         
        msg = { :status => 200, :message => "Success",:leader_detail=>final_leader}
        render :json => msg
      end

      
      def user_profile_info
      @user = User.joins(:user_profile)
                   .select("users.*,user_profiles.location,user_profiles.bio,user_profiles.picture_file_name,user_profiles.profile_pic_path,user_profiles.reecher_interests,user_profiles.reecher_fav_music,user_profiles.reecher_fav_movies,user_profiles.reecher_fav_books,user_profiles.reecher_fav_sports,user_profiles.reecher_fav_destinations,user_profiles.snippet")
                   .where("users.reecher_id =?" ,params[:user_id])
      
      
                   
      profile_obj = UserProfile.find_by_reecher_id(@user[0][:reecher_id].to_s)
      picture_file =  @user[0][:picture_file_name].to_s
      profile_pic  =  @user[0][:profile_pic_path].to_s
      if !picture_file.blank?
       image_url =  profile_obj.picture_url      
      elsif !profile_pic.blank?
        image_url = profile_pic.to_s
      else
        image_url = nil
      end 
      
      
      user_hash = {}
      @user.each do |u|
        user_hash =u.attributes
      end
      
      tot_curio = get_curio_points(params[:user_id])
      #tot_curio = current_user.points
      tot_quest = get_user_total_question(params[:user_id])
      tot_sol = get_user_total_solution(params[:user_id])
      tot_conn = get_user_total_connection(params[:user_id])
      
      user_hash[:image_url] = image_url
      user_hash[:curio_points] = tot_curio
      user_hash[:total_questions_asked] = tot_quest
      user_hash[:total_solutions_provided] = tot_sol
      user_hash[:total_connections] =tot_conn
      msg = { :status => 200, :user_details => user_hash}
      render :json =>msg            

     end
      
     def picture_from_url(url)
     self.picture = open(url)
     end 
    

		end
	end
end

