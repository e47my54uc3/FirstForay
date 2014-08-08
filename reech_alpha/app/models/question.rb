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
  #default_scope { where(:published_at => Time.now - 1.week) }
  def create_question_id
    self.question_id=gen_question_id
  end

 def self.filterforuser user_id , question_list_obj
   questions = question_list_obj
   @Questions =[]
   if !questions.blank?
      questions.each do |q|
        question_asker = q.posted_by_uid
        #puts "question_askerquestion_asker=#{question_asker}"
        question_user = User.find_by_reecher_id(question_asker)
        #question_asker_name = q.posted_by
        question_asker_name = question_user.full_name
        question_is_public = q.is_public
        @pqtfs = PostQuestionToFriend.where("question_id = ?", q.question_id)
        solution_posted_by_login_user = Solution.where( "solver_id = ? AND question_id =? ", user_id , q.question_id)
        #puts "!solution_posted_by_login_user=#{question_asker}"
        if !solution_posted_by_login_user.empty?
          solution_posted_by_login_user_id = solution_posted_by_login_user.collect{|sol| sol.id}
        end
        purchased_sl_by_question_owner = PurchasedSolution.where(:user_id => question_asker)
        if !purchased_sl_by_question_owner.empty?
          purchased_sl_by_question_owner = purchased_sl_by_question_owner.collect {|s| s.solution_id}
        end
        reecher_user_associated_to_question=@pqtfs.collect{|pq| pq.friend_reecher_id} if !@pqtfs.blank?

        if ((!purchased_sl_by_question_owner.blank?) && (!solution_posted_by_login_user_id.blank?))
          match_ids= solution_posted_by_login_user_id & purchased_sl_by_question_owner
          if match_ids.size > 0
            #q[:question_referee] = q.posted_by
            q[:question_referee] = question_asker_name
            q[:no_profile_pic] = false
          end
        elsif (( user_id ==  question_asker) || question_is_public)
          #q[:question_referee] = q.posted_by
          q[:question_referee] = question_asker_name
          q[:no_profile_pic] = false
        elsif(!@pqtfs.blank? && (reecher_user_associated_to_question.include? user_id))
          #q[:question_referee] = q.posted_by
          q[:question_referee] = question_asker_name
          q[:no_profile_pic] = false
        else
          q[:question_referee] = "Friend"
          q[:no_profile_pic] = true
        end
        @Questions << q
      end
    else
      @Questions = []
    end
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
