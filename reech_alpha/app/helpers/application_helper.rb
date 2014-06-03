module ApplicationHelper
  def message_person(mailbox_name, message)
    mailbox_name == 'inbox' ? message.sender : message.recipient_list.join(', ')
  end

  def send_device_notification device_token,message,platform
     puts "platform-before=#{platform}"
    if platform == 'iOS' 
      puts "platform123=#{platform}"
      n1= APNS::Notification.new(device_token, :alert => message, :badge => 1, :sound => 'default')
      APNS.send_notifications([n1])
    elsif platform =='Andriod'
      destination = device_token
      data1       = message
      options1    = {:collapse_key => "placar_score_global", :time_to_live => 3600, :delay_while_idle => false}
      GCM.send_notification( destination,data1,options1 )
    end

  end

  def check_notify_question_when_answered user_id
    # UserSettings.find_bu_pushnotif_is_enabled_and_notify_question_when_answered
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

end
