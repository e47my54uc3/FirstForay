class Solution < ActiveRecord::Base
	attr_accessible :body, :solver, :solver_id, :down, :up, :ask_charisma, :linked_user
	belongs_to :forquestion,
	:class_name => 'Question',
	:primary_key => 'question_id',
	:foreign_key => 'question_id'

	belongs_to :wrote_by,
	:class_name => 'User',
	:primary_key => 'beamer_id',
	:foreign_key => 'solver_id'

	has_many :purchased_solutions
	has_many :users, :through => :purchased_solutions

end
