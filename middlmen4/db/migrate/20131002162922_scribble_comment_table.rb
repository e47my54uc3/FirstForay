class ScribbleCommentTable < ActiveRecord::Migration
  def up
  	create_table "scribble_comments", :force => true do |t|
	    t.string   "commentor_id"
	    t.string   "commentor"
	    t.text     "body",                        :null => false
	    t.integer  "ups",          :default => 0
	    t.integer  "downs",        :default => 0
	    t.string   "scribble_id"
	    t.datetime "created_at",                  :null => false
	    t.datetime "updated_at",                  :null => false
	  end
  end

  def down
  	drop_table "scribble_comments"
  end
end
