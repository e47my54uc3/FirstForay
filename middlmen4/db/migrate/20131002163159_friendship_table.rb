class FriendshipTable < ActiveRecord::Migration
  def up
  	create_table "friendships", :force => true do |t|
	    t.string   "beamer_id"
	    t.string   "friend_beamer_id"
	    t.string   "status"
	    t.datetime "created_at"
	  end
  end

  def down
  	drop_table "friendships"
  end
end
