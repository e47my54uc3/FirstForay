class CreateUserSettings < ActiveRecord::Migration
  def change
    create_table :user_settings do |t|
      t.boolean :location_is_enabled
      t.boolean :pushnotif_is_enabled
      t.boolean :emailnotif_is_enabled
      t.boolean :notify_question_when_answered
      t.boolean :notify_linked_to_question
      t.boolean :notify_solution_got_highfive

      t.timestamps
    end
  end
end
