class CreatePostQuestionToFriends < ActiveRecord::Migration
  def change
    create_table :post_question_to_friends do |t|
      t.string :user_id     
      t.text   :friend_reecher_id
      t.timestamps
    end
  end
end
