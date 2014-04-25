class PreviewSolution < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :user_id, :solution_id
  belongs_to :user
  belongs_to :solution
end
