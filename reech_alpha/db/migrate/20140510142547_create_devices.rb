class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :device_token
      t.string :platform
      t.string :reecher_id
      t.timestamps
    end
  end
end
