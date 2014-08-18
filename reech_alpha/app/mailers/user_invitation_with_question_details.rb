class UserInvitationWithQuestionDetails < ActionMailer::Base
  include ApplicationHelper

  default :from => "hello@reechout.co", :mime_type =>"multipart/mixed"
  #default from: "from@example.com"
  def send_linked_question_details(email, user,token,referral_code,question_id,linked_quest_type)
    @user  = user
    @email = email
    @token = token
    @referral_code = referral_code
    @question_id = question_id
    @linked_quest_type = linked_quest_type
    if question_id != 0
       mail(to:  email, subject: "You've been referred to a question on Reech")
    else
       mail(to:  email, subject: "Your friends are Reeching, are you?")
    end
  end 
  
end
