class AddPictureColumnsToUserProfile < ActiveRecord::Migration
  def self.up
    change_table :user_profiles do |t|
      t.attachment :picture
      t.string :location , :null => true
    end
  end

  def self.down
    drop_attached_file :user_profiles, :picture
    remove_column :user_profiles, :location
  end
end
