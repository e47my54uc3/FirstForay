module Api
	module V1
	  require "open-uri"
		class UserProfileController < ApiController
		before_filter :restrict_access, :except => [:forget_password]	
		respond_to :json
				
				def index					
					if !current_user
						msg = {:status => 400, :message => "User does not exist."}
						render :json => msg
					else
						@profile = current_user.user_profile.attributes
						@profile[:hi5] = current_user.user_profile.votes_for.size
						current_user.user_profile.picture_file_name != nil ? @profile[:image_url] =  current_user.user_profile.picture_url : @profile[:image_url] = nil
						msg = {:status => 200, :user => current_user, :profile => @profile ,:curio_points=> current_user.points }
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
		             #current_user_session.destroy if !current_user_session.n:reecheridil?
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
              UserMailer.send_new_password_as_forgot_password(@user,pass_token).deliver    unless @user.email.blank?
               client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
                sms = client.account.sms.messages.create(
                          from: TWILIO_CONFIG['from'],
                          to: @user.phone_number,
                          body: "Username= #{@user.original_phone_number} and Temporary password= #{pass_token}"  
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
					@all_connections = current_user.friends.select("first_name, last_name, email,friend_reecher_id")
					render json: {:status=> 200, :message => @all_connections.nil? ? "No connections" : @all_connections}
				end

				def profile_dash_board					
					current_user.present? ? msg = {:status => 200, :questions => current_user.questions.size, :solutions => current_user.solutions.size, :connections => current_user.friendships.accepted.size} : msg = {:status => 400, :message => "User doesn't exist"}
					render :json => msg
				end	

				def profile_hi5
					#voting_user = User.find_by_reecher_id(params[:user_id])
					votable_user = User.find_by_reecher_id(params[:votable_user_id])
					current_user.user_profile.liked_by(current_user)
					msg = {:status => 200 , :message => "Success"}
					render :json => msg
				end	

				def add_contact
				 @user = User.find_by_reecher_id(params[:user_id])
						if !params[:contact_details].nil?

							if !params[:contact_details][:email].nil?
								UserMailer.send_invitation_email_for_new_contact(params[:contact_details][:email], @user).deliver  unless params[:contact_details][:email].blank?
                 msg = {:status => 200, :message => "Email sent to the contact."}
							end	

							if !params[:contact_details][:phone_number].nil?
							  
							  
								client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
								begin
								sms = client.account.sms.messages.create(
        							from: TWILIO_CONFIG['from'],
        							to: params[:contact_details][:phone_number],
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
        @user=User.find_by_reecher_id(params[:user_id])
        all_friend_of_users= @user.friendships.where(:status =>"accepted").pluck(:friend_reecher_id) if !@user.blank?
        all_friend_of_users.unshift(@user.reecher_id)
        all_users = User.where(:reecher_id=>all_friend_of_users) if !all_friend_of_users.empty?
        if ((!@user.blank?) && (!all_users.blank?))
        today_user_details =[]        
        weekly_user_details =[]
        monthly_user_details =[]
        current_user_hash_for_today =[]
        current_user_hash_for_week =[]
        current_user_hash_for_month =[]
         if (!all_users.blank?)
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
            #Todays calculation           
            tot_question = get_user_total_question user.reecher_id
            tot_answer = get_user_total_solution user.reecher_id
            tot_hi5 = user.user_profile.votes_for.size 
            tot_curios = user.points
            #position = ((0.3 * tot_curios) + (0.7*tot_hi5)).floor
            #(15%)Total curios + (20%)# of questions asked + (30%)# of solutions provided + (35%)# of hi5 received
            today_position = ((0.15 * tot_curios) + (0.2* tot_question) + (0.3*tot_answer) + (0.35*tot_hi5))          
            today_user_details.push({"position" => today_position,"reecherid"=>user.reecher_id,"reechername"=>user.first_name+" "+ user.last_name,"reecherimage"=>image_url,"level"=>7,"scores"=> {"points_earned" => tot_curios ,"questions_asked" =>tot_question, "answers_given" =>tot_answer,"high_fives" =>tot_hi5}})
            #Week calculation
            #Todays calculation           
            tot_week_question = get_user_total_week_question user.reecher_id
            tot_week_answer = get_user_total_week_solution user.reecher_id
            tot_hi5 = user.user_profile.votes_for.size 
            tot_week_curios = get_weekly_points user.sash_id
            #(15%)Total curios + (20%)# of questions asked + (30%)# of solutions provided + (35%)# of hi5 received
            weekly_position = ((0.15 * tot_curios) + (0.2* tot_question) + (0.3*tot_answer) + (0.35*tot_hi5))          
            weekly_user_details.push({"position" => weekly_position,"reecherid"=>user.reecher_id,"reechername"=>user.first_name+" "+ user.last_name,"reecherimage"=>image_url,"level"=>7,"scores"=> {"points_earned" => tot_week_curios ,"questions_asked" =>tot_week_question, "answers_given" =>tot_week_answer,"high_fives" =>tot_hi5}})
            #Monthly calculation
            tot_month_question = get_user_total_month_question user.reecher_id
            tot_month_answer = get_user_total_month_solution user.reecher_id
            tot_hi5 = user.user_profile.votes_for.size 
            tot_month_curios = get_monthly_points user.sash_id
            #(15%)Total curios + (20%)# of questions asked + (30%)# of solutions provided + (35%)# of hi5 received
            monthly_position = ((0.15 * tot_curios) + (0.2* tot_question) + (0.3*tot_answer) + (0.35*tot_hi5))          
            monthly_user_details.push({"position" => monthly_position,"reecherid"=>user.reecher_id,"reechername"=>user.first_name+" "+ user.last_name,"reecherimage"=>image_url,"level"=>7,"scores"=> {"points_earned" => tot_month_curios ,"questions_asked" =>tot_month_question, "answers_given" =>tot_month_answer,"high_fives" =>tot_hi5}})
          end
         end
         
       puts "today_user_details===#{today_user_details.to_yaml}"  
       puts "weekly_user_details===#{weekly_user_details.to_yaml}"  
       puts "monthly_user_details===#{monthly_user_details.to_yaml}"  
         
        #Today
        current_user_hash_for_today =   today_user_details.select{ |hsh| hsh  if hsh.has_value? params[:user_id]}
        sort_user_for_today_detail = today_user_details.sort_by{ |h| h["position"]}.reverse
        sort_user_for_today_detail =sort_user_for_today_detail.take(5)
        #Week
        current_user_hash_for_week =   weekly_user_details.select{ |hsh| hsh  if hsh.has_value? params[:user_id]}
        sort_user_for_week_detail = weekly_user_details.sort_by{ |h| h["position"]}.reverse
        sort_user_for_week_detail =sort_user_for_week_detail.take(5)
        #Month
        current_user_hash_for_month =   monthly_user_details.select{ |hsh| hsh  if hsh.has_value? params[:user_id]}
        sort_user_for_month_detail = monthly_user_details.sort_by{ |h| h["position"]}.reverse
        sort_user_for_month_detail = sort_user_for_month_detail.take(5)
        
        final_leader[:today]= {"user_position"=>current_user_hash_for_today,"top_positions"=> sort_user_for_today_detail}
        final_leader[:week]= {"user_position"=>current_user_hash_for_week,"top_positions"=> sort_user_for_week_detail}
        final_leader[:month] = {"user_position"=>current_user_hash_for_month,"top_positions"=> sort_user_for_month_detail}
        msg = { :status => 200, :message => "Success",:leader_detail=>final_leader}
        else
        msg = { :status => 401, :message => "Failure"}  
        end  
        render :json => msg
      end

      
      def user_profile_info
      	render "user_profile_info.json.jbuilder"
     	end
      
     def picture_from_url(url)
       self.picture = open(url)
     end 
    

		end
	end
end

