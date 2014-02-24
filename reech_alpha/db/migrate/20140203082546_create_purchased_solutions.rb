class CreatePurchasedSolutions < ActiveRecord::Migration
  def change
    create_table :purchased_solutions do |t|
      t.string :user_id
      t.string :solution_id
      t.timestamps

    end
  end
end
