class NewsFeedTable < ActiveRecord::Migration
  def up
  	create_table "newsfeeds", :force => true do |t|
	    t.string   "verb"
	    t.string   "activity"
	    t.string   "actor_id"
	    t.string   "actor_type"
	    t.string   "actor_name_method"
	    t.string   "indirect_actor_id"
	    t.string   "indirect_actor_type"
	    t.string   "indirect_actor_name_method"
	    t.integer  "count",                      :default => 1
	    t.string   "object_id"
	    t.string   "object_type"
	    t.string   "object_name_method"
	    t.integer  "privacystatus",              :default => 0
	    t.datetime "created_at",                                :null => false
	    t.datetime "updated_at",                                :null => false
	  end
  end

  def down
  	drop_table "newsfeeds"
  end
end
