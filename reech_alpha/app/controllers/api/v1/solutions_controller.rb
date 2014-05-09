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

				if !params[:expert_details].nil?
					if !params[:expert_details][:emails].nil?
						# if the expert is in reech network directly link the question 
						# Otherwise send an simple email to him
						params[:expert_details][:emails].each do |email|
							linked_user = User.find_by_email(email)
							if linked_user.present?
								linked_question = LinkedQuestion.where(:user_id => linked_user.reecher_id, :question_id => params[:question_id], :linked_by_uid => @solver.reecher_id)
								if !linked_question.present?
									link_question = LinkedQuestion.new
									link_question.user_id = linked_user.reecher_id
									link_question.question_id = params[:question_id]
									link_question.linked_by_uid = @solver.reecher_id
									link_question.save
								end	
							else
								UserMailer.send_link_question_email(email, @solver).deliver
							end	
						end	
					end

					if !params[:expert_details][:phone_numbers].nil?
						client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
						params[:expert_details][:phone_numbers].each do |number|
							sms = client.account.sms.messages.create(
        							from: TWILIO_CONFIG['from'],
        							to: number,
        							body: "your friend #{@solver.first_name} #{@user.last_name}  want to solve his friend's question on Reech."
      						)
      						logger.debug ">>>>>>>>>Sending sms to #{number} with text #{sms.body}"
						end
					end	
				end	

				if @solution.save
					msg = {:status => 200, :solution => @solution}
				else
					msg = {:status => 400, :message => "Failed"}
				end	
				render :json => msg
			end

			def purchase_solution
				user = User.find_by_reecher_id(params[:user_id])
				solution = Solution.find(params[:solution_id])
				purchased_sl = PurchasedSolution.where(:user_id => user.id, :solution_id => solution.id)
				if purchased_sl.present?
					msg = {:status => 400, :message => "You have Already Purchased this Solution."}
				else	
					if user.points > solution.ask_charisma
						purchased_solution = PurchasedSolution.new
						purchased_solution.user_id = user.id
						purchased_solution.solution_id = solution.id
						purchased_solution.save
						preview_solution = PreviewSolution.find_by_user_id_and_solution_id(user.id, solution.id)
						preview_solution.destroy

						#Add points to solution provider
						solution_provider = User.find_by_reecher_id(solution.solver_id)
						solution_provider.add_points(solution.ask_charisma)

						#Revert back the points to user who post the question
						user.add_points(solution.ask_charisma)

						msg = {:status => 200, :message => "Success"}
					else
						msg = {:status => 400, :message => "Sorry, you need at least #{solution.ask_charisma} Charisma Credits to purchase this Solution! Earn some by providing Solutions!"}
					end	
				end
				render :json => msg
			end	

			def view_solution
				solution = Solution.find(params[:solution_id])
				@solution = solution.attributes
				@solution[:hi5] = solution.votes_for.size
				solution.picture_file_name != nil ? @solution[:image_url] = "http://#{request.host_with_port}" + solution.picture_url : @solution[:image_url] = nil
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
						sl.picture_file_name != nil ? solution_attrs[:image_url] = "http://#{request.host_with_port}" + sl.picture_url : solution_attrs[:image_url] = "http://#{request.host_with_port}/"+"no-image.png"
						purchased_sl = PurchasedSolution.where(:user_id => user.id, :solution_id => sl.id)
						if purchased_sl.present?
							solution_attrs[:purchased] = true
						else
							solution_attrs[:purchased] = false	
						end	
						@solutions << solution_attrs
					end	
				end
				msg = {:status => 200, :solutions => @solutions} 
				logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{@solutions}"

				render :json => msg
			end	


			def preview_solution
				@user = User.find_by_reecher_id(params[:user_id])
				@solution = Solution.find(params[:solution_id])
				@preview_solution = PreviewSolution.where(:user_id => @user.id, :solution_id => @solution.id)
				if @preview_solution.present? 
				  msg = {:status => 400, :message => "You have to purchase this solution."}
				else
					preview_solution = PreviewSolution.new
					preview_solution.user_id = @user.id
					preview_solution.solution_id = @solution.id
					preview_solution.save
					msg = {:status => 200, :solution => @solution}
				end	
				render :json => msg
			end	

			def previewed_solutions
				@user = User.find_by_reecher_id(params[:user_id])
				previewed_solutions = @user.preview_solutions
				solution_ids = []
				if previewed_solutions.size > 0
					previewed_solutions.each do |ps|
						solution_ids << ps.solution_id
					end
				end	
				msg = {:status => 200, :solution_ids => solution_ids}
				logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{solution_ids}"
				render :json => msg
			end	

			def solution_hi5
				solution = Solution.find(params[:solution_id])
				user = User.find_by_reecher_id(params[:user_id])
				solution.liked_by(user)
				@solution = solution.attributes
				@solution[:hi5] = solution.votes_for.size
				solution.picture_file_name != nil ? @solution[:image_url] = "http://#{request.host_with_port}" + solution.picture_url : @solution[:image_url] = nil
				msg = {:status => 200, :solution => @solution}
				render :json => msg
			end	

		end
	end
end			