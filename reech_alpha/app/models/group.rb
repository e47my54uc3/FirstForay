class Group < ActiveRecord::Base
  attr_accessible :name,:reecher_id
  has_and_belongs_to_many :users
  validates :name, uniqueness: { :scope => [:reecher_id], :case_sensitive => false}
  def self.get_group_association user_id, group_id

    ActiveRecord::Base.connection.select("SELECT * FROM `groups_users` WHERE group_id =#{group_id} AND user_id = #{user_id}")
    #ActiveRecord::Base.connection.select("SELECT * FROM `groups_users` WHERE user_id = #{user_id}")
  end

  def self.reecher_personal_groups user_id
    user = User.find_by_reecher_id(user_id)   unless user_id.blank?
    groups = Group.select("id,name").where("reecher_id =?",user.reecher_id)
  #  msg = {:status => 200, :groups =>groups }
    #render :json => msg
  end
  
  
  def self.get_friend_associated_groups user_id ,friend_id
    ActiveRecord::Base.connection.select("SELECT A.group_id 
FROM  `groups_users` A, groups B WHERE A.group_id = B.id AND B.reecher_id =  '#{user_id}' AND A.user_id = #{friend_id} ORDER BY user_id")
  end
end
