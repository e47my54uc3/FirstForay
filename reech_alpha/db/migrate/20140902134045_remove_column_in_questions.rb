class RemoveColumnInQuestions < ActiveRecord::Migration
  def up
  	remove_column :questions, :catgory_id
  end
end
