class CreateSendReechRequests < ActiveRecord::Migration
  def change
    create_table :send_reech_requests do |t|
      t.string    :user_id
      t.string    :type
      t.string    :contact_details
      t.timestamps
    end
  end
end
