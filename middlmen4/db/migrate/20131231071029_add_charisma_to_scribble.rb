class AddCharismaToScribble < ActiveRecord::Migration
  def change
    add_column :scribbles, :Charisma, :integer
  end
end
