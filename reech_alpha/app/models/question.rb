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
			 # if question owner have add current login user for this question then his will show otherwise it will show Friend  
			#	puts "current_user--object#{current_user.inspect}"
				#puts "question--object#{q.inspect}"
			#	puts "question--posted_by_uid#{q.posted_by_uid}"
				#puts "question--question_id#{q.question_id}"
			#	puts "current_user==#{current_user.inspect}"
				#question_owner_name = Question::show_question_owner_name(current_user.reecher_id, q.question_id, q.posted_by_uid)
				@question_owner_name = PostQuestionToFriend.where("user_id = ? AND friend_reecher_id= ? AND question_id = ?", q.posted_by_uid, current_user.reecher_id, q.question_id)
				checked_is_question_linked = LinkedQuestion.where("question_id = ?",q.question_id)				
				#puts "@question_owner_name#{@question_owner_name.inspect}"
				#purchased_sl = PurchasedSolution.where(:user_id => current_user.id, :solution_id => sl.id)
				
				if @question_owner_name.size > 0
				 q[:question_referee] = q.posted_by
				 q[:no_profile_pic] = false 
				elsif (checked_is_question_linked == 0 && @question_owner_name.size == 0)
				 q[:question_referee] = q.posted_by
         q[:no_profile_pic] = false 
				elsif current_user.reecher_id == q.posted_by_uid
				 q[:question_referee] = q.posted_by		
				 q[:no_profile_pic] = false          		  
				else
				 @all_sol= Solution.where(:question_id=>q.question_id) 
				 unless @all_sol.blank?
				 all_sol_id   = @all_sol.collect{|sol| sol.id}
				 all_user = PurchasedSolution.where(:solution_id=>all_sol_id)
				 get_all_user = all_user.collect{ |u| u.user_id} unless all_user.blank?
				 all_reecher_id = User.where(:id=>get_all_user) unless all_user.blank?
				 all_reecher = all_reecher_id.collect{|ur| ur.reecher_id} unless all_reecher_id.blank?
								if (!all_reecher.blank?) && (all_reecher.include? q.posted_by_uid)
            		   q[:question_referee] =  q.posted_by
                   q[:no_profile_pic] = false 
    				   else
    				    q[:question_referee] = "Friend"  
                q[:no_profile_pic] = true 
    				   end
				 else  
				    q[:question_referee] = "Friend"  
            q[:no_profile_pic] = true
				 end
				 			  			 
				end
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
  
  def avatar_geometry(style = :medium)
  @geometry ||= {}
  photo_path = (avatar.options[:storage] == :s3) ? avatar.url(style) : avatar.path(style)
  puts "photo_path== #{photo_path.inspect}"
  @geometry[style] ||= Paperclip::Geometry.from_file(photo_path)
  end	

 def show_question_owner_name (current_user_id ,question_id,question_owner)
 owner_name = false
 @pqtf = PostQuestionToFriend.select.where("user_id = ? AND friend_reecher_id=? AND question_id =?", question_owner, current_user_id, question_id)
 if pqtf.blank?
   owner_name
  else
   owner_name = true  
 end 
  owner_name
  
end 
  
def check_question_refer_to_me user_id , friend_reecher_id, question_id
  @question_owner_name = PostQuestionToFriend.where("user_id = ? AND friend_reecher_id= ? AND question_id = ?", q.posted_by_uid, current_user.reecher_id, q.question_id)
  
end
  
  
  
end
