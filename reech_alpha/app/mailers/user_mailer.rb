class UserMailer < ActionMailer::Base
  default from: "noreplay@reechout.com"

  def password_reset_instructions(user)
  	@user = user
    @url  = edit_password_reset_url(user.persistence_token)
    mail(to:  user.email, subject: "Password Reset Instructions")
  end

  def send_invitation_email_for_audien(email,user)
  	@user = user
  	mail(to:  email, subject: "Invitation to singup Reechout")
  end	

  def send_invitation_email_for_new_contact(email,user)
    @user = user
    mail(to:  email, subject: "Invitation to singup Reechout")
  end

  def send_link_question_email(email, user)
    @user = user
    mail(to:  email, subject: "Invitation to Answer a question in Reechout")
  end  
  
  def send_reech_friend_request(email, user)
    @user = user
    mail(to:  email, subject: "Invitation to Reech Friend")
  end  

  def send_question_details_to_audien(email,user)
    @user = user
    mail(to:  email, subject: "Question posted on Reechout")
  end


end
