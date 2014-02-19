class ScribbleTable < ActiveRecord::Migration
  def up
  	create_table "scribbles", :force => true do |t|
	    t.string   "post"
	    t.string   "posted_by"
	    t.string   "posted_by_uid"
	    t.datetime "created_at",    :null => false
	    t.datetime "updated_at",    :null => false
	    t.integer  "ups"
	    t.integer  "downs"
	    t.string   "scribble_id",   :null => false
	  end
  end

  def down
    drop_table "scribbles"
  end
end
