class Solution < ActiveRecord::Base
	attr_accessible :body, :solver, :solver_id, :down, :up, :ask_charisma, :linked_user
	acts_as_votable
	belongs_to :forquestion,
	:class_name => 'Question',
	:primary_key => 'question_id',
	:foreign_key => 'question_id'

	belongs_to :wrote_by,
	:class_name => 'User',
	:primary_key => 'reecher_id',
	:foreign_key => 'solver_id'

	has_attached_file :picture, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"


	has_many :purchased_solutions
	has_many :users, :through => :purchased_solutions
	has_many :preview_solutions

  validates_attachment :picture, :content_type => { :content_type => "image/jpeg" } , unless: Proc.new { |record| record[:picture].nil? }


def buy(soln)
	solution.ask_charisma = soln

end

def self.filter(question, current_user)
	solns = []
	allsolutions = question.posted_solutions
	allsolutions.each do |answer|
		if answer.users.exists?(current_user)
			solns = solns + answer
		end
	end
end

def picture_url
	picture.url(:medium)
end

def picture_original_url
  picture.url(:original)
end
def picture_thumb_url
  picture.url(:thumb)
end


end
