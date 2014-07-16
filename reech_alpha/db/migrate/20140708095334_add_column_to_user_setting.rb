class AddColumnToUserSetting < ActiveRecord::Migration
  def self.up
    add_column  :user_settings, :notify_audience_if_ask_for_help, :boolean
    add_column  :user_settings, :notify_when_someone_grab_my_answer, :boolean
  end
  def self.down
    remove_column :user_settings, :notify_audience_if_ask_for_help
    remove_column :user_settings, :notify_when_someone_grab_my_answer
  end
end
