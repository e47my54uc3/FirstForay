module Api
	module V1
		class SolutionsController < ApiController
		before_filter :restrict_access
		respond_to :json	

			def create
				@solver = User.find_by_reecher_id(params[:user_id])
				@solution = Solution.create(params[:solution])
				@solution.question_id = params[:question_id_val]
				@solution.solver_id = @solver.reecher_id
				@solution.solver = "#{@solver.first_name} #{@solver.last_name}"
				@solution.ask_charisma = @solution.ask_charisma 
				@solution.linked_user = @solution.linked_user	
				@solution.save
				
			end

		end
	end
end			