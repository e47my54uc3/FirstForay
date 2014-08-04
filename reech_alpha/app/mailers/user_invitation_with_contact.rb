class UserInvitationWithContact < ActionMailer::Base
  
  default :from => "hello@reechout.co", :mime_type =>"multipart/mixed"
  #default from: "from@example.com"
  def invite_friend(email, user,token)
    @user  = user
    @email = email
    rand_str = (('A'..'Z').to_a + (0..9).to_a)
    token = (0...32).map { |n| rand_str.sample }.join
    @token = token
    #@referral_code = referral_code
    #@question_id = question_id
    mail(to:  email, subject: "Your friend @user.full_name needs your help…")
  end 
  
end
