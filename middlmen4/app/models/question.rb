include Scrubber
class Question < ActiveRecord::Base
  has_merit

  attr_accessible :post, :posted_by, :posted_by_uid,:question_id, :points, :Charisma
  before_save :create_question_id
  
  has_many :posted_solutions,
  :class_name => 'Solution',
  :primary_key=>'question_id',
  :foreign_key => 'question_id',
  :order => "solutions.created_at DESC"

  def create_scribble_id
    self.question_id=gen_question_id
  end
end
