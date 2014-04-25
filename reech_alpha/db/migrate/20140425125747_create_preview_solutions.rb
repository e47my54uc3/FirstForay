class CreatePreviewSolutions < ActiveRecord::Migration
  def change
    create_table :preview_solutions do |t|
    	t.integer :user_id
    	t.integer :solution_id
      t.timestamps
    end
  end
end
