class AddNotifyWhenMyStaredQuestionGetAnswerToUsersetting < ActiveRecord::Migration
  def change
    add_column :user_settings, :notify_when_my_stared_question_get_answer, :boolean
  end
end
