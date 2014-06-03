class AddEmailIdAndPhoneNoToLinkedQuestion < ActiveRecord::Migration
  def change
    add_column :linked_questions, :email_id, :string
    add_column :linked_questions, :phone_no, :string
  end
end
