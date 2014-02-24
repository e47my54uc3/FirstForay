class AddCharismaToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :Charisma, :integer
  end
end
