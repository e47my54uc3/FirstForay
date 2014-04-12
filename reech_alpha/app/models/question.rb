include Scrubber
class Question < ActiveRecord::Base
	has_merit

	attr_accessible :post, :posted_by, :posted_by_uid,:question_id, :points, :Charisma, :avatar, :has_solution, :stared, :image_url
	has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
 
	#do_not_validate_attachment_file_type :avatar
	validates_attachment :avatar, :content_type => { :content_type => "image/jpeg" } , unless: Proc.new { |record| record[:avatar].nil? }

	#validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
	before_save :create_question_id
	
	belongs_to :user, :foreign_key => 'posted_by_uid', :primary_key => 'reecher_id'
	has_many :votings, :dependent => :destroy

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
		@Qpostedbyuser = Question.where(:posted_by_uid => current_user.reecher_id)
		#@Questions = @Qpostedbyuser.collect{|question| {:value=>question.id, :label=>question.post}}
		@Questions = []
		@Questions << @Qpostedbyuser
		@Qbyfriendship = Question.includes(:posted_solutions, :votings).find(:all, :order => 'questions.created_at DESC')
			@Qbyfriendship.each do |question|
				@posting_user = question.posted_by_uid
				if Friendship.are_friends(@posting_user,current_user.reecher_id)
					 @Questions << question
				end
			end
			@Questions = @Questions.flatten
	end

	def self.get_stared_questions(user_id)
		@stared_questions = []
		stared_question_ids = []
		user = User.find_by_reecher_id(user_id)
		stared_questions = user.votings #Voting.all
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

	def is_stared?
	 self.votings.size > 0 ? true : false
	end  

end
