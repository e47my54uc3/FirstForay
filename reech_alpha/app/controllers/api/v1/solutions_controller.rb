module Api
	module V1
		class SolutionsController < ApiController
		before_filter :restrict_access
		respond_to :json	

			def create
				@solver = User.find_by_reecher_id(params[:user_id])
				@solution = Solution.new(params[:solution])
				@solution.question_id = params[:question_id]
				@solution.solver_id = @solver.reecher_id
				@solution.solver = "#{@solver.first_name} #{@solver.last_name}"
				@solution.ask_charisma = params[:ask_charisma] 
				@solution.save
				if @solution.save
					msg = {:status => 200, :solution => @solution}
				else
					msg = {:status => 400, :message => "Failed"}
				end	
			end

			def view_solution
				solution = Solution.find(params[:solution_id])
				@solution = solution.attributes
				@solution[:hi5] = solution.votes.size
				msg = {:status => 200, :solution => @solution} 
				render :json => msg
			end	

			def solution_hi5
				solution = Solution.find(params[:solution_id])
				user = User.find_by_reecher_id(params[:user_id])
				solution.liked_by(user)
				@solution = solution.attributes
				@solution[:hi5] = solution.votes.size
				msg = {:status => 200, :solution => @solution}
				render :json => msg
			end	

		end
	end
end			