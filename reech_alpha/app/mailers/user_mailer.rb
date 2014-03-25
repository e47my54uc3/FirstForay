class UserMailer < ActionMailer::Base
  default from: "noreplay@reechout.com"

  def password_reset_instructions(user)

  	@user = user
    @url  = edit_password_reset_url(user.persistence_token)
    mail(to:  user.email, subject: "Password Reset Instructions")
  end

end