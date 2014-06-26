class CreateInviteUsers < ActiveRecord::Migration
  def change
    create_table :invite_users do |t|
      t.string :linked_question_id     
      t.text   :token
      t.string :referral_code     
      t.datetime :token_validity_time
      t.timestamps
    end
  end
end
