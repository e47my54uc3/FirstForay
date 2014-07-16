class AddColumnCategoryIdToQuestions < ActiveRecord::Migration
  def self.down
  	 remove_column :questions, :catgory_id
 end
 def self.up
    add_column  :questions, :category_id, :integer
    
 end
end 
