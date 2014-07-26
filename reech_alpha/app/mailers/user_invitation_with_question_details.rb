class UserInvitationWithQuestionDetails < ActionMailer::Base
  include ApplicationHelper

  default :from => "vijayprasad83@gmail.com", :mime_type =>"multipart/mixed"
  #default from: "from@example.com"
  def send_linked_question_details(email, user,token,referral_code,question_id)
    @user  = user
    @email = email
    @token = token
    @referral_code = referral_code
    @question_id = question_id
    if question_id != 0
       mail(to:  email, subject: "Invitation to Answer a question in Reechout")
    else
       mail(to:  email, subject: "Invitation to join Reechout")
    end
  end 
  
end
