class UserProfile < ActiveRecord::Base

	serialize :reecher_interests, Array
	serialize :reecher_hobbies, Array
	serialize :reecher_fav_music, Array
	serialize :reecher_fav_movies, Array
	serialize :reecher_fav_books, Array
	serialize :reecher_fav_sports, Array
	serialize :reecher_fav_destinations, Array
	serialize :reecher_fav_cuisines, Array 

  attr_accessible :reecher_interests,:reecher_hobbies,:reecher_fav_music,:reecher_fav_movies,:reecher_fav_books,
  								:reecher_fav_sports,:reecher_fav_destinations,:reecher_fav_cuisines,:bio,:snippet
  
  belongs_to :user,:primary_key=>:reecher_id,:foreign_key=>:reecher_id

  validates_presence_of :reecher_id, :message => "No Reecher ID was passed! Profile couldn't be created."
  validates :bio, :length => { :maximum => 500, :message => "can only be a maximum of 500 characters long" }

end