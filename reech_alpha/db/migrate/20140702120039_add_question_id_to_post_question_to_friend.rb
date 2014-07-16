class AddQuestionIdToPostQuestionToFriend < ActiveRecord::Migration
  def change
    add_column  :post_question_to_friends, :question_id, :string
  end
end
