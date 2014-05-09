class CreateLinkedQuestions < ActiveRecord::Migration
  def change
    create_table :linked_questions do |t|
    	t.string :user_id, :question_id, :linked_by_uid
      t.timestamps
    end
  end
end
