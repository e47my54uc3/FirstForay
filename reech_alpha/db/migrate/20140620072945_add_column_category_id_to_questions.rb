class AddColumnCategoryIdToQuestions < ActiveRecord::Migration
  def change
  	 remove_column :questions, :catgory_id, :integer
     add_column  :questions, :category_id, :integer
  end
end
