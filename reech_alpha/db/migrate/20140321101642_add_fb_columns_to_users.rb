class AddFbColumnsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :fb_token, :string
  	add_column :users, :fb_uid, :string
  end
end
