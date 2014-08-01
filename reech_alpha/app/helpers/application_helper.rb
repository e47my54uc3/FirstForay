module ApplicationHelper
 
  def message_person(mailbox_name, message)
    mailbox_name == 'inbox' ? message.sender : message.recipient_list.join(', ')
  end

  def send_device_notification device_token,message,platform,title="Title"
     
     puts "device_token=#{device_token}"
     puts "message123=#{message}"
     puts "platform=#{platform}"
     puts "title===#{title.inspect}"      
            
    if platform == 'iOS' 
      puts "I am in iOS mobile notification"
      n1= APNS::Notification.new(device_token, :alert => title, :badge => 1, :sound => 'default',:other=>{:message=>message,:title=>title,:badge => 1})
      APNS.send_notifications([n1])
      puts "iOS response ==#{response.inspect}"
    elsif platform =='Android'
      puts "I am in Android mobile notification"
      require 'gcm'
      gcm = GCM.new("AIzaSyA8LPahDEVgdPxCU4QrWOh1pF_IL655LNI")
      registration_ids= [device_token] # an array of one or more client registration IDs
      options = {data: {payload_body:message ,message: title ,title:"Reech"}, collapse_key: "Reech",time_to_live:3600}
      response = gcm.send_notification(registration_ids, options)
      #puts "response==#{response.inspect}"
    end

  end

  def check_notify_question_when_answered user_id
    #UserSettings.find_bu_pushnotif_is_enabled_and_notify_question_when_answered
    user = User.find_by_reecher_id(params[:user_id])
    setting =user.user_settings
     if ((setting[:pushnotif_is_enabled] == true ) && (setting[:notify_question_when_answered] == true))
     check =true
    else
     check =false
    end
    check 
  end

  def notify_linked_to_question user_id
    # UserSettings.find_bu_pushnotif_is_enabled_and_notify_question_when_answered
    user = User.find_by_reecher_id(params[:user_id])
    setting =user.user_settings
    if ((setting[:pushnotif_is_enabled]== true) && (setting[:notify_linked_to_question] == true))
      check =true
    else
       check =false
    end
    check
  end

   
  def notify_when_my_stared_question_get_answer user_id
    user = User.find_by_reecher_id(params[:user_id])
    setting =user.user_settings
    if ((setting[:pushnotif_is_enabled]== true) && (setting[:notify_when_my_stared_question_get_answer] == true))
      check =true
    else
       check =false
    end
    check
  end
  
  def notify_solution_got_highfive user_id
    user = User.find_by_reecher_id(params[:user_id])
    setting =user.user_settings
    if ((setting[:pushnotif_is_enabled]== true) && (setting[:notify_solution_got_highfive] == true))
      check =true
    else
      check =false
    end
    check
  end
  
  
  def notify_audience_if_ask_for_help user_id
    user = User.find_by_reecher_id(params[:user_id])
    setting =user.user_settings
    if ((setting[:pushnotif_is_enabled]== true) && (setting[:notify_audience_if_ask_for_help] == true))
      check =true
    else
      check =false
    end
    check
    
  end
  
  def notify_when_someone_grab_my_answer user_id
    user = User.find_by_reecher_id(params[:user_id])
    setting =user.user_settings
    if ((setting[:pushnotif_is_enabled]== true) && (setting[:notify_when_someone_grab_my_answer] == true))
      check =true
    else
      check =false
    end
    check
 end
  
  
  def get_curio_points user_id
  
  @user1 = User.find_by_reecher_id(user_id)
  points = @user1.points
  
  end
  
  def get_user_total_question user_id
    
  @user2 = User.find_by_reecher_id(user_id)
  tot_question = @user2.questions.size
  
  end
  
  def get_user_total_solution user_id
    
  sols = Solution.where(:solver_id=>user_id)
  tot_sol = sols.size
  end
  
  def get_user_total_connection user_id
    
  @user4 = User.find_by_reecher_id(user_id)
  tot_question = @user4.friendships.size
  
  end
  
  def make_friendship_standard(friends, user)
    # Proceed only if both the IDs are not same 
    if friends != user
	    are_friends1 = Friendship::are_friends(friends,user)
	    are_friends2 = Friendship::are_friends(user,friends)
	    
	    if !are_friends1
		    friend =  Friendship.new()
		    friend.reecher_id = friends
		    friend.friend_reecher_id = user
		    friend.status = "accepted"
		    friend.save
	    end
	    if !are_friends2
		    friend2 =  Friendship.new()
		    friend2.reecher_id = user
		    friend2.friend_reecher_id = friends
		    friend2.status = "accepted"
		    friend2.save
	    end
    else
	  puts "Error : Cant make friendship between same users." 
    end
  end  
  
  def filter_phone_number phone_number  
    puts "filter_phone_number has received phone_number===#{phone_number}" 
    phone_number.strip
    check_plus_sign = phone_number.chr
    phone_num = "+" + phone_number.gsub(/[^0-9]/, '')
=begin    
    if check_plus_sign == "+"      
      phone_num = "+" + phone_number.gsub(/[^0-9]/, '')
    else
      phone_num =  "+"+ phone_number.gsub(/[^0-9]/, '')      
    end
    phone_num
=end

    
  end  

  
  def linked_question_with_type linker_id,user_id="",question_id, email,phone,linked_type_str
             @linkquest = LinkedQuestion.new()
             @linkquest.user_id =user_id
             @linkquest.question_id = question_id
             @linkquest.linked_by_uid = linker_id
             @linkquest.email_id = email
             @linkquest.phone_no = phone
             @linkquest.linked_type = linked_type_str
             @linkquest.save
             #@rand_has_key = random_key_generator(Time.now)
             rand_str = (('A'..'Z').to_a + (0..9).to_a)
             token = (0...32).map { |n| rand_str.sample }.join
             referral_code = (0...8).map { |n| rand_str.sample }.join
             validity= 15.days.from_now
             tries = 0
             invite_user_object= InviteUser.create(:linked_question_id=>@linkquest.id,:token=>token,:referral_code=>referral_code,:token_validity_time =>validity)
        
          arr =[]
          arr.push(:referral_code=>referral_code)  
          arr.push(:token=>token)
          arr
    
  end
       
  def send_posted_question_notification_to_chosen_phones audien_details ,user,question,push_title_msg,push_contant_str,linked_quest_type
    # Check whether the audience details contains the phone numbers list or not
    if audien_details.has_key?("phone_numbers")  
      # If the phone numbers list is present, check whether it is empty or not   
      if !audien_details[:phone_numbers].empty? 
        # If the list is not empty then we have to proceed and send sms to these numbers
        # Create a twilio client in order to send sms
        client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
        # Loop over all the phone numbers in the list
        audien_details[:phone_numbers].each do |number|
          # Extract the phone number and apply the filtering on it so that special characters can b removed   
          number = filter_phone_number(number)
          # Try to find the whether this phone no. is associated with an existing user
          user_details_for_phone = User.find_by_phone_number(number) 
          # If the phone belongs to a registered user then we have to send notification to his/her logged in device
          # Check whether the phone number belongs to a registered user or not
          if user_details_for_phone.present?                                          
            # Double check that the registered user's phone number is present
            if !user_details_for_phone.blank?
              # Find out the registered users device ID
              device_details = Device.where(:reecher_id=>user_details_for_phone.reecher_id)
              # If a valid device ID is present then we will send notification to the associated device
              if !device_details.blank?
                # Send notifcation fo ASKHELP type
                if question !=0
                notify_string = "#{push_contant_str},"  + "<"+ user.full_name + ">" + ","+ question.question_id.to_s + "," + Time.now().to_s
                elsif question ==0
                notify_string = "#{push_contant_str},"  + "<"+ user.full_name + ">" + "," + Time.now().to_s  
                end  
                
                device_details.each do |d|
                  send_device_notification(d[:device_token].to_s, notify_string ,d[:platform].to_s,user.full_name+push_title_msg)
                end
              end
            end
            
            # Now check whether the email ID of the registered user is present or not
            if !user_details_for_phone.blank? && user_details_for_phone.email != nil
              # Chandan commented the line below as it is no required
              # phone_number = filter_phone_number(user_details_for_phone.phone_number)
            begin 
              puts ""
              client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
                        sms = client.account.sms.messages.create(
                        from: TWILIO_CONFIG['from'],
                        #to: phone_number,
                        to: number,
                        body: "Your friend #{user.first_name} #{user.last_name} needs your help answering a question on Reech. Sign-in & help them out."
                      )
              logger.debug ">>>>>>>>>Sending sms to #{phone_number} with text #{sms.body}"        
              rescue Exception => e
	      logger.error e.to_s
              end
            end                                          

            LinkedQuestion.create(:user_id =>user_details_for_email.reecher_id,:question_id=>question.question_id,:linked_by_uid=>user.reecher_id,:email_id=>email,:phone_no=>user_details_for_email.phone_number,:linked_type=>linked_quest_type)                                        
           make_friendship_standard(user_details_for_phone.reecher_id, user.reecher_id)               
        else
          # This case is for non-registered users
          # Find out the referral code which has been generated for this question by the reecher who asked this question
            if question !=0
             get_referal_code_and_token = linked_question_with_type user.reecher_id,question.question_id,'',number,linked_quest_type
             refral_code = get_referal_code_and_token[0][:referral_code]
              elsif question == 0             
             get_referal_code_and_token = linked_question_with_type user.reecher_id , 0, '' , number , linked_quest_type
             refral_code = get_referal_code_and_token[0][:referral_code]
            end 
          
          
          # phone_number = filter_phone_number(user_details_for_phone.phone_number) 
          # phone_number = "+919873992110"
          
           begin   
           puts " Before sending sms MY NUMBER = #{number}"
            client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])    
                      sms = client.account.sms.messages.create(
                      from: TWILIO_CONFIG['from'],
                      to: number,
                      body: "Hey! Got a minute? Your friend #{user.first_name} #{user.last_name} needs your help on Reech. Visit http://reechout.co to download the app and help them out. Invite code: #{refral_code}"
                     )
             logger.debug ">>>>>>>>>Sending sms to #{number} with text"      
             puts " After sending sms MY NUMBER = #{number}"  
             rescue Exception => e
              logger.error e.to_s
            end
          end 
        end 
      end 
    end 
  end
 
 
  def send_posted_question_notification_to_chosen_emails audien_details ,user,question,push_title_msg,push_contant_str,linked_quest_type
    if !audien_details.blank? 
         if  audien_details.has_key?("emails")             
                        if !audien_details["emails"].empty?
                             audien_reecher_ids = []
                               audien_details["emails"].each do |email|
                                user_details_for_email = User.find_by_email(email)
                                # If audien is a reecher store his reedher_id in question record
                                # Else send an Invitation mail to the audien
                                    if user_details_for_email.present?
                                          audien_reecher_ids << user_details_for_email.reecher_id
                                          #send notification to existing user
                                            if !user_details_for_email.blank?
                                               device_details = Device.where(:reecher_id=>user_details_for_email.reecher_id)
                                               if !device_details.blank?
                                                  if question !=0
                                                  notify_string = "#{push_contant_str}," + "<" + user.full_name + ">" + ","+ question.question_id + "," + Time.now().to_s 
                                                  elsif question ==0
                                                  notify_string = "#{push_contant_str}," + "<"+  user.full_name + ">" + "," + Time.now().to_s
                                                  end  
                                                  
                                                  device_details.each do |d|
                                                  send_device_notification(d[:device_token].to_s, notify_string ,d[:platform].to_s,user.full_name+push_title_msg)
                                                end
                          
                                              end
                                            end
                                            
                                            if !user_details_for_email.blank? && user_details_for_email.phone_number != nil
                                             phone_number = filter_phone_number(user_details_for_email.phone_number)
                                               begin
                                               client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])                                                               
                                                sms = client.account.sms.messages.create(
                                                    from: TWILIO_CONFIG['from'],
                                                    to: phone_number,
                                                    body: "Hey! Got a minute? Your friend #{user.first_name} #{user.last_name} needs your help on Reech. Visit http://reechout.co to download the app and help them out. Invite code: #{refral_code}"
                                                )
                                                logger.debug ">>>>>>>>>Sending sms to #{phone_number} with text #{sms.body}"
                                               rescue Exception => e
                                               logger.error e.to_s
                                               end 
                                            end   
                                         puts " Before linked question"       
                                        LinkedQuestion.create(:user_id =>user_details_for_email.reecher_id,:question_id=>question.question_id,:linked_by_uid=>user.reecher_id,:email_id=>email,:phone_no=>user_details_for_email.phone_number,:linked_type=>linked_quest_type)   
                                        puts " after linked question"
                                        make_friendship_standard(user_details_for_email.reecher_id, user.reecher_id)
                                        puts " after friend linked question"                                           
                                    else
                                     
                                       begin
                                          if question !=0
                                             get_referal_code_and_token = linked_question_with_type user.reecher_id,question.question_id,'',email,linked_quest_type
                                             UserInvitationWithQuestionDetails.send_linked_question_details(email,user,get_referal_code_and_token[0][:token],get_referal_code_and_token[0][:referral_code],question.question_id,linked_quest_type).deliver
                                          elsif question == 0
                                             get_referal_code_and_token = linked_question_with_type user.reecher_id , 0 , '' , email , linked_quest_type
                                             UserInvitationWithQuestionDetails.send_linked_question_details(email,user,get_referal_code_and_token[0][:token],get_referal_code_and_token[0][:referral_code],0,linked_quest_type).deliver
                                              
                                          end
                                       rescue Exception => e
                                         logger.error e.to_s
                                       end
                                      
                                    end 
                              end 
                          question.audien_user_ids = audien_reecher_ids if audien_reecher_ids.size > 0
                        end 
                   end
         
         end
  end
  

end
