class UserProfile < ActiveRecord::Base

	serialize :beamer_interests, Array
	serialize :beamer_hobbies, Array
	serialize :beamer_fav_music, Array
	serialize :beamer_fav_movies, Array
	serialize :beamer_fav_books, Array
	serialize :beamer_fav_sports, Array
	serialize :beamer_fav_destinations, Array
	serialize :beamer_fav_cuisines, Array 

  attr_accessible :beamer_interests,:beamer_hobbies,:beamer_fav_music,:beamer_fav_movies,:beamer_fav_books,
  								:beamer_fav_sports,:beamer_fav_destinations,:beamer_fav_cuisines,:bio,:snippet
  
  belongs_to :user,:primary_key=>:beamer_id,:foreign_key=>:beamer_id

  validates_presence_of :beamer_id, :message => "No Beamer ID was passed! Profile couldn't be created."
  validates :bio, :length => { :maximum => 500, :message => "can only be a maximum of 500 characters long" }

end