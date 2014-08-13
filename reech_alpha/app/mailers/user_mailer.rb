class UserMailer < ActionMailer::Base
  include ApplicationHelper
  default :from => "hello@reechout.co", :mime_type =>"multipart/mixed"
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

  def email_question_when_answered(email,solver_details,question_details)
    @solver_details = solver_details
    @question_details = question_details
    mail(to:  email, subject: "Solution provided on Reech Question #{@question_details.post}")
  end
  
  def email_solution_got_highfive(email,user,solution_title) 
    @user = user
    @solution_title = solution_title
    mail(to:  email, subject: "Solution got Hi Five Reech #{@solution_title}")
  end  
  
  def email_when_my_stared_question_get_answer(email,user,question_details)    
    @user = user
    @question_details = question_details
    mail(to:  email, subject: "My Starred question got answer #{@question_details.post}")
    
  end

end
