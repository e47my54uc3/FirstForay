class UserProfileTable < ActiveRecord::Migration
  def up
  	create_table "user_profiles", :force => true do |t|
	    t.string  "reecher_id"
	    t.text     "reecher_interests"
	    t.text     "reecher_hobbies"
	    t.text     "reecher_fav_music"
	    t.text     "reecher_fav_movies"
	    t.text     "reecher_fav_books"
	    t.text     "reecher_fav_sports"
	    t.text     "reecher_fav_destinations"
	    t.text     "reecher_fav_cuisines"
	    t.text   	 "bio"
	    t.string   "snippet"
  	end
  	add_index "user_profiles", ["reecher_id"], :name => "index_user_profiles_on_reecher_id"

  end

  def down
  	drop_table "user_profiles"
  end
end
