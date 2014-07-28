class AddColumnIsPublicToQuestionTable < ActiveRecord::Migration
  def change
     add_column  :questions, :is_public, :boolean ,:default =>0,:after=>:Charisma
  end
end
