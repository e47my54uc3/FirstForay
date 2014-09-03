
class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	#devise :database_authenticatable, :registerable,
	#       :recoverable, :rememberable  #, :trackable, :validatable

	# Setup accessible (or protected) attributes for your model
	attr_accessible :email,:phone_number ,:password, :password_confirmation, :remember_me
	has_merit
	acts_as_voter

	include BCrypt
	include Scrubber

	#For OmniAuth
	has_many :authorizations, :dependent => :destroy

	
	#For Authlogic
	acts_as_authentic do |c|
		c.ignore_blank_passwords = true #ignoring passwords
		c.login_field = :phone_number
		c.validate_login_field =false
	end

	attr_accessible :email, :first_name, :last_name, :password, :password_confirmation, :points
	serialize :omniauth_data, JSON
	#Scrubber Fields
	before_create :create_unique_profile_id
	before_create :create_reecher_id
	validates :email, uniqueness: true ,:allow_blank => true, :allow_nil => true
	validates :phone_number, uniqueness: true ,:allow_blank => true, :allow_nil => true 
	#Authentications
	validate do |user|
		if user.new_record? #adds validation if it is a new record
			user.errors.add(:first_name, "First Name Field cannot be blank") if user.first_name.blank?
			user.errors.add(:last_name, "Last Name Field cannot be blank") if user.last_name.blank?
			user.errors.add(:password, "is required") if user.password.blank?
		 elsif !(!user.new_record? && user.password.blank?) #adds validation only if password is modified
			user.errors.add(:first_name, "First Name Field cannot be blank") if user.first_name.blank?
			user.errors.add(:first_name, "Last Name Field cannot be blank") if user.last_name.blank?
			user.errors.add(:password, "is required") if user.password.blank?
			user.errors.add(:password, " and should be atleast 4 characters long.") if user.password.length < 4 || user.password_confirmation.length < 4
		end
	end

	# friendships
	has_many :friendships,:primary_key=>"reecher_id",:foreign_key=>'reecher_id'
	has_many :friends, 
					 :through => :friendships,
					 :conditions => "status = 'accepted'"

	has_many :requested_friends, 
					 :through => :friendships, 
					 :source => :friend,
					 :conditions => "status = 'requested'", 
					 :order => :created_at

	has_many :pending_friends, 
					 :through => :friendships, 
					 :source => :friend,
					 :conditions => "status = 'pending'", 
					 :order => :created_at

	#Questions
	has_many :questions, :primary_key=>"reecher_id",:foreign_key=>'posted_by_uid'
	has_many :post_question_to_friends

	has_many :votings, :through => :questions , :dependent => :destroy
  
  
  has_and_belongs_to_many :groups, join_table: "groups_users", uniq: true
  has_many :owned_groups, class_name: "Group", primary_key: 'reecher_id', foreign_key: 'reecher_id'
	# purchased solutions
	has_many :purchased_solutions
	has_many :solutions, :through => :purchased_solutions

	#Messages
	has_many :messages, class_name: 'Message', foreign_key: 'user_id'


	#Profile
	has_one :user_profile, :primary_key => :reecher_id, :foreign_key => :reecher_id, :dependent => :destroy
	delegate :reecher_interests, :reecher_hobbies, :reecher_fav_music, :reecher_fav_movies, 
					 :reecher_fav_books, :reecher_fav_sports, :reecher_fav_destinations,
					 :reecher_fav_cuisines, :bio, :snippet,:reecher_interests=, :reecher_hobbies=, :reecher_fav_music=,
					 :reecher_fav_movies=,:reecher_fav_books=, :reecher_fav_sports=, :reecher_fav_destinations=,
					 :reecher_fav_cuisines=, :bio=, :snippet=,
					 :to => :user_profile

	has_one :user_settings, :primary_key=>:reecher_id,:foreign_key=>:reecher_id, :dependent => :destroy
	
	has_many :preview_solutions	

	#Linked questions
	has_many :linked_questions, :primary_key=>"reecher_id", :foreign_key=>"user_id"
	
	# Devices association for push notifications
	has_many :devices, :primary_key=>"reecher_id", :foreign_key=>"reecher_id" 
	
	# Alias Profile of a reecher to be called User Profile or Reecher Profile
	alias_attribute :reecher_profile,:user_profile

	accepts_nested_attributes_for :user_profile

	after_create :create_reecher_profile, :create_user_settings


	def self.create_from_omniauth_data(omniauth_data)
		user = User.new(
			:first_name => omniauth_data['info']['name'].to_s.downcase,
			:email => omniauth_data['info']['email'].to_s.downcase #if present
			)
		user.omniauth_data = omniauth_data.to_json #shove OmniAuth::AuthHash as json data to be parsed later!
		user.save(:validate => false) #create without validations because most of the fields are not set.
		user.reset_persistence_token! #set persistence_token else sessions will not be created
		user
	end

  def all_groups
  	owned_groups + groups
  end

  def name 
  	full_name
  end

  def image_url 
  	user_profile.image_url
  end
  def reecherId
  	reecher_id
  end
	def create_reecher_id
		self.reecher_id=gen_reecher_id
	end

	def create_unique_profile_id
		self.profile_id=gen_profile_id
	end

	def full_name
		return "#{self.first_name} #{self.last_name}"
	end

	def location
		user_profile.location if user_profile
	end

	def get_friend_associated_groups friend
		#copied from original needs refactoring
		group_ids = Group::get_friend_associated_groups friend ,self.id
		user_group_ids =[]
		group_ids.each do |i|
			user_group_ids.push(i.values)
		end
		user_group_ids.flatten!
	end

	def prefix
		try(:full_name) || email
	end

	def message_title
		"#{prefix} <#{email}>"
	end

	def to_s
		full_name
	end

	def mailbox
		Mailbox.new(self)
	end
	

	# after_create callback to create new profile associated with the Reecher
	def create_reecher_profile
		reecher_profile = UserProfile.new
		reecher_profile.reecher_id = self.reecher_id
		reecher_profile.save!
	end

	def create_user_settings
		user_settings = UserSettings.new
		user_settings.reecher_id = self.reecher_id
		user_settings.location_is_enabled = true
		user_settings.pushnotif_is_enabled = true
		user_settings.emailnotif_is_enabled = true
		user_settings.notify_question_when_answered = true
		user_settings.notify_linked_to_question = true
		user_settings.notify_solution_got_highfive = true
		user_settings.notify_audience_if_ask_for_help = true
		user_settings.notify_when_someone_grab_my_answer = true
		user_settings.notify_when_my_stared_question_get_answer = true
		user_settings.save!
	end	

	def deliver_password_reset_instructions!
		reset_persistence_token!
		UserMailer.password_reset_instructions(self).deliver
	end
	
  def picture_from_url(url)
    self.picture = open(url)
  end

  
end
