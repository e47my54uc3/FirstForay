class AddColumnOriginalPhoneNumberToUser < ActiveRecord::Migration
  def change
     add_column  :users, :original_phone_number, :string ,:after=>:phone_number,:limit=>15
  end
end
