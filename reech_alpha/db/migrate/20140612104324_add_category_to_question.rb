class AddCategoryToQuestion < ActiveRecord::Migration
   def self.up
    add_column :questions, :catgory_id, :integer
    
  end

  def self.down
    remove_column :questions, :catgory_id
    
  end
end
