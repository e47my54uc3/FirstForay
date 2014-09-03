class AddIsPublicToSolutionTables < ActiveRecord::Migration
  def change
    #solution is public by default if :is_public =1
    #solution is private if :is_public =0
    add_column  :solutions, :is_public, :boolean ,:default =>1,:after=>:ask_charisma
  end
end
