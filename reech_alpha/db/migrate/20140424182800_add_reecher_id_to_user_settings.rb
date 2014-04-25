class AddReecherIdToUserSettings < ActiveRecord::Migration
  def change
    add_column :user_settings, :reecher_id, :string
  end
end
