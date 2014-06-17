include Scrubber
class Question < ActiveRecord::Base
	has_merit

	attr_accessible :post,:id, :posted_by, :posted_by_uid,:question_id, :points, :Charisma, :avatar, :has_solution, :stared, :image_url, :audien_user_ids
	has_attached_file :avatar, :styles => {:medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png" ,:default_style => :original 
 serialize :audien_user_ids, Array
	#do_not_validate_attachment_file_type :avatar
	validates_attachment :avatar, :content_type => { :content_type => "image/jpeg" } , unless: Proc.new { |record| record[:avatar].nil? }
  
	#validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
	before_save :create_question_id
	
	belongs_to :user, :foreign_key => 'posted_by_uid', :primary_key => 'reecher_id'
	has_many :votings, :dependent => :destroy
  has_many :solutions, :primary_key=>'question_id',:foreign_key => 'question_id',:dependent => :destroy 
	
	has_many :posted_solutions,
	:class_name => 'Solution',
	:primary_key=>'question_id',
	:foreign_key => 'question_id',
	:order => "solutions.created_at DESC"

	def create_question_id
		self.question_id=gen_question_id
	end

	def self.filterforuser(user_id)
		current_user = User.find_by_reecher_id("#{user_id}")
		
=begin
		@Qpostedbyuser = Question.where(:posted_by_uid => current_user.reecher_id).order('created_at DESC')
		#@Questions = @Qpostedbyuser.collect{|question| {:value=>question.id, :label=>question.post}}
		@Questions = []
		@Qpostedbyuser.each do |qby_user|
			@Questions << qby_user
		end	
		
		@Qbyfriendship = Question.find(:all, :order => 'created_at DESC')
			@Qbyfriendship.each do |question|
				@posting_user = question.posted_by_uid
				if Friendship.are_friends(@posting_user,current_user.reecher_id)
					 @Questions << question
				end
			end
			@Questions
=end
			friends_reecher_ids = []
			friends_reecher_ids << current_user.reecher_id
			user_friends = Friendship.where(:reecher_id => current_user.reecher_id, :status => 'accepted')
			if user_friends.size > 0
				user_friends.each do |uf|
					friends_reecher_ids << uf.friend_reecher_id
				end	
			end
			@Questions = []
			questions = Question.where(:posted_by_uid => friends_reecher_ids).order("created_at DESC")
			questions.each do |q|
				@Questions << q
			end	
			@Questions
	end

	def self.get_stared_questions(user_id)
		@stared_questions = []
		stared_question_ids = []
		user = User.find_by_reecher_id(user_id)
		stared_questions = user.votings #Voting.all
		
		puts "stared_questions=#{stared_questions}"
		if stared_questions.size > 0
			stared_questions.each do |sq|
				stared_question_ids << sq.question_id
			end
		@stared_questions = find(stared_question_ids)   
		end  
		@stared_questions
	end

	def avatar_url
		avatar.url(:medium)
	end

  def avatar_original_url
    avatar.url(:original)
  end
	def is_stared?
	 self.votings.size > 0 ? true : false
	end  

  def get_geometry(style = :original)
    begin
      Paperclip::Geometry.from_file(pic.path(style)).to_s
    rescue
      nil
    end
  end
  
  
  
end
