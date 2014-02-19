class UserProfileTable < ActiveRecord::Migration
  def up
  	create_table "user_profiles", :force => true do |t|
	    t.string  "beamer_id"
	    t.text     "beamer_interests"
	    t.text     "beamer_hobbies"
	    t.text     "beamer_fav_music"
	    t.text     "beamer_fav_movies"
	    t.text     "beamer_fav_books"
	    t.text     "beamer_fav_sports"
	    t.text     "beamer_fav_destinations"
	    t.text     "beamer_fav_cuisines"
	    t.text   	 "bio"
	    t.string   "snippet"
  	end
  	add_index "user_profiles", ["beamer_id"], :name => "index_user_profiles_on_beamer_id"

  end

  def down
  	drop_table "user_profiles"
  end
end
