class ModifiedTableColumnInDeviceAndUser < ActiveRecord::Migration
  def change
     change_column(:devices, :device_token, :text)
     change_column(:users, :phone_number, :string, after: :email ,:limit => 15)
  end
 
end
