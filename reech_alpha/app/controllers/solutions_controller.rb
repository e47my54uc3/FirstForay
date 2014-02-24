class SolutionsController < ApplicationController
	def create
		@solver = User.find_by_reecher_id(params[:solver_id_val])
		@solution = Solution.create(params[:solution])
		@solution.question_id=params[:question_id_val]
		@solution.solver_id=@solver.reecher_id
		@solution.solver = "#{@solver.first_name} #{@solver.last_name}"
		@solution.ask_charisma=@solution.ask_charisma 
		@solution.linked_user=@solution.linked_user	
		@solution.save
		redirect_to root_url
	end

end
