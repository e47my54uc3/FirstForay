class AddColumnPhoneNumberToUser < ActiveRecord::Migration
  def change
    add_column :users, :phone_number, :string, after: :email ,:limit => 11
  end
end
