class AddAudienColumnToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :audien_user_ids, :text, :null => true
  end

  def self.down
    remove_column :questions, :audien_user_ids
  end
end
