module Api
	module V1
		class SolutionsController < ApiController
		before_filter :restrict_access
		respond_to :json	

			def create
				@solver = User.find_by_reecher_id(params[:user_id])
				@solution = Solution.new()
				@solution.body = params[:solution]
				@solution.question_id = params[:question_id]
				@solution.solver_id = @solver.reecher_id
				@solution.solver = "#{@solver.first_name} #{@solver.last_name}"
				@solution.ask_charisma = params[:ask_charisma] 

				if !params[:solution_image].blank? 
					data = StringIO.new(Base64.decode64(params[:solution_image]))
					@solution.picture = data
				end

				if @solution.save
					msg = {:status => 200, :solution => @solution}
				else
					msg = {:status => 400, :message => "Failed"}
				end	
				render :json => msg
			end

			def view_solution
				solution = Solution.find(params[:solution_id])
				@solution = solution.attributes
				@solution[:hi5] = solution.votes_for.size
				msg = {:status => 200, :solution => @solution} 
				render :json => msg
			end	

			def view_all_solutions
				solutions = Solution.find_all_by_question_id(params[:question_id])
				@solutions = []
				if solutions.size > 0
					solutions.each do |sl|
						solution_attrs = sl.attributes
						user = User.find_by_reecher_id(sl.solver_id)
						user.user_profile.picture_file_name != nil ? solution_attrs[:solver_image] = "http://#{request.host_with_port}" + user.user_profile.picture_url : solution_attrs[:solver_image] = nil
						sl.picture_file_name != nil ? solution_attrs[:image_url] = "http://#{request.host_with_port}" + sl.picture_url : solution_attrs[:image_url] = nil
						@solutions << solution_attrs
					end	
				end
				msg = {:status => 200, :solutions => @solutions} 
				logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{@solutions.size}"

				render :json => msg
			end	


			def preview_solution
				@user = User.find_by_reecher_id(params[:user_id])
				@solution = Solution.find(params[:solution_id])
				@preview_solution = PreviewSolution.where(:user_id => @user, :solution_id => @solution.id)
				if @preview_solution.present? 
				  msg = {:status => 400, :message => "You have to purchase this solution."}
				else
					preview_solution = PreviewSolution.new
					preview_solution.user_id = @user.id
					preview_solution.solution_id = @solution.id
					preview_solution.save
					msg = {:status => 200, :solution => @solution}
				end	
			end	

			def solution_hi5
				solution = Solution.find(params[:solution_id])
				user = User.find_by_reecher_id(params[:user_id])
				solution.liked_by(user)
				@solution = solution.attributes
				@solution[:hi5] = solution.votes_for.size
				msg = {:status => 200, :solution => @solution}
				render :json => msg
			end	

		end
	end
end			