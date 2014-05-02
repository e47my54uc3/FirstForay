class AddAttachmentColumnsToSolutions < ActiveRecord::Migration
	
 	def self.up
    change_table :solutions do |t|
      t.attachment :picture
    end
  end

  def self.down
    drop_attached_file :solutions, :picture
  end
end
