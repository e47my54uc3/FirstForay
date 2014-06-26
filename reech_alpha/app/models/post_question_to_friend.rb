class PostQuestionToFriend < ActiveRecord::Base
  # attr_accessible :title, :body
  
  def get_referred_friend_ids user_id
    
    reech_ids = PostQuestionToFriend.select("friend_reecher_id").where(:user_id =>user_id)
    
    
  end 
    
end
