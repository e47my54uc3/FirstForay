class Category < ActiveRecord::Base
  attr_accessible :title
  
    def self.get_category_list user_id
            user= User.find_by_reecher_id(user_id)  
            @categories = Category.select("id,title").all unless user.blank?  
           
    end
end
