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

end
