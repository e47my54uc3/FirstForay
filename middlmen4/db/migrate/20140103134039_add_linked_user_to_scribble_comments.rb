class AddLinkedUserToScribbleComments < ActiveRecord::Migration
  def change
    add_column :scribble_comments, :linked_user, :string
  end
end
