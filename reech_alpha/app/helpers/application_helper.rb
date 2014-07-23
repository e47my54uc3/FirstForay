module ApplicationHelper
 
  def message_person(mailbox_name, message)
    mailbox_name == 'inbox' ? message.sender : message.recipient_list.join(', ')
  end

  def send_device_notification device_token,message,platform,title="Title"
     
     puts "device_token=#{device_token}"
     puts "message=#{message}"
     puts "platform=#{platform}"
     puts "title===#{title.inspect}"      
            
    if platform == 'iOS' 
      puts "I am in iOS mobile notification"
      n1= APNS::Notification.new(device_token, :alert => title, :badge => 1, :sound => 'default',:other=>{:message=>message,:title=>title,:badge => 1})
      APNS.send_notifications([n1])
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
  end  
  

def filter_phone_number phone_number    
    phone_number.strip!
    check_plus_sign = phone_number.chr
    if check_plus_sign == "+"      
      phone_num = "+" + phone_number.gsub(/[^0-9]/, '')
    else
      phone_num =  phone_number.gsub(/[^0-9]/, '')      
    end
    
   phone_num
    
  end  
  
  
 

end
