class AddFieldsToScribbles < ActiveRecord::Migration
  def self.up
    add_column :scribbles, :sash_id, :integer
    add_column :scribbles, :level, :integer, :default => 0
  end

  def self.down
    remove_column :scribbles, :sash_id
    remove_column :scribbles, :level
  end
end
