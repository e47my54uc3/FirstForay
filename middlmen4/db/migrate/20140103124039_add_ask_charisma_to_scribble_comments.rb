class AddAskCharismaToScribbleComments < ActiveRecord::Migration
  def change
    add_column :scribble_comments, :ask_charisma, :integer
  end
end
