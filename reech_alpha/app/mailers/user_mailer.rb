class UserMailer < ActionMailer::Base
  include ApplicationHelper
  default :from => "vijayprasad83@gmail.com", :mime_type =>"multipart/mixed"
=begin
  def password_reset_instructions(user)
  	@user = user
    @url  = edit_password_reset_url(user.persistence_token)
    mail(to:  user.email, subject: "Password Reset Instructions")
  end
=end

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

  def send_new_password_as_forgot_password(user,new_passwd)
    @user = user
    @new_password = new_passwd
    puts " I am sending email to forgot password user =#{@user.email}"
    email = (@user.email).to_s
    mail(to:  @user.email, subject: "Password Reset Reech")
   
  end

end
