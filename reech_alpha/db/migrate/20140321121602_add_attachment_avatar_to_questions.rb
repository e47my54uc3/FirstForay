class AddAttachmentAvatarToQuestions < ActiveRecord::Migration
  def self.up
    change_table :questions do |t|
      t.attachment :avatar
    end
  end

  def self.down
    drop_attached_file :questions, :avatar
  end
end
