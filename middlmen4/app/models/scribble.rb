include Scrubber
class Scribble < ActiveRecord::Base
  has_merit

  attr_accessible :post, :posted_by, :posted_by_uid,:scribble_id, :points, :Charisma
  before_save :create_scribble_id
  
  has_many :posted_comments,
  :class_name => 'ScribbleComment',
  :primary_key=>'scribble_id',
  :foreign_key => 'scribble_id',
  :order => "scribble_comments.created_at DESC"

  def create_scribble_id
    self.scribble_id=gen_scribble_id
  end
end
