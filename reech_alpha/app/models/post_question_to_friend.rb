class PostQuestionToFriend < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  belongs_to :question
  belongs_to :posted_to, class_name: "User", primary_key: "reecher_id", foreign_key: "friend_reecher_id"
  
  def get_referred_friend_ids user_id
    
    reech_ids = PostQuestionToFriend.select("friend_reecher_id").where(:user_id =>user_id)
    
    
  end 
    
end
