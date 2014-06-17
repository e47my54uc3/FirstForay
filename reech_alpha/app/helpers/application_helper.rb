module ApplicationHelper
 
  def message_person(mailbox_name, message)
    mailbox_name == 'inbox' ? message.sender : message.recipient_list.join(', ')
  end

  def send_device_notification device_token,message,platform
            
    if platform == 'iOS' 
      n1= APNS::Notification.new(device_token, :alert => message, :badge => 1, :sound => 'default')
      APNS.send_notifications([n1])
    elsif platform =='Android'
      require 'gcm'
      gcm = GCM.new("AIzaSyA8LPahDEVgdPxCU4QrWOh1pF_IL655LNI")
      registration_ids= [device_token] # an array of one or more client registration IDs
      options = {data: {message: message}, collapse_key: "Reech",time_to_live:3600}
      response = gcm.send_notification(registration_ids, options)
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
    # UserSettings.find_bu_pushnotif_is_enabled_and_notify_question_when_answered
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
    # UserSettings.find_bu_pushnotif_is_enabled_and_notify_question_when_answered
    user = User.find_by_reecher_id(params[:user_id])
    setting =user.user_settings
    if ((setting[:pushnotif_is_enabled]== true) && (setting[:notify_solution_got_highfive] == true))
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
    
  @user3 = User.find_by_reecher_id(user_id)
  tot_question = @user3.solutions.size
  
  end
  
  def get_user_total_connection user_id
    
  @user4 = User.find_by_reecher_id(user_id)
  tot_question = @user4.friendships.size
  
  end
  
   
   
   


end
