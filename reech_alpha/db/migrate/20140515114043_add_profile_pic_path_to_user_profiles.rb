class AddProfilePicPathToUserProfiles < ActiveRecord::Migration
  def change
  	add_column :user_profiles, :profile_pic_path, :string
  end
end
