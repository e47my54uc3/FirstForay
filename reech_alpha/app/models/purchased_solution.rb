class PurchasedSolution < ActiveRecord::Base
  #attr_accessible :solution_id, :user_id
  belongs_to :user
  belongs_to :solution

  scope :questions, ->(arg) do
  	includes(:solutions).where(user_id: arg).references(:solutions).pluck("solution.question_id")
  end
end
