class ChatTable < ActiveRecord::Migration
  def up
  	create_table :chats do |t|
  		t.string   :broadcasted_by
  		t.string	 :broadcasted_to
  		t.text  :message
      t.timestamps
  	end
  	add_index :chats , :broadcasted_to
  	add_index :chats , :broadcasted_by
  	add_index :chats , [:broadcasted_by,:broadcasted_to]
  end

  def down
  	drop_table :chats
  end
end
