module Api
	module V1
		class QuestionsController < ApiController
		#http_basic_authenticate_with name: "admin", password "secret"
		before_filter :restrict_access
		#doorkeeper_for :all
		respond_to :json

		def index
			@Questions = []
			@Questions = Question.filterforuser(params[:user_id])	
			#if params[:type] == "feed"
				#@Questions = Question.filterforuser(params[:user_id])			
			#elsif params[:type] == "stared"
			 	#@Questions = Question.get_stared_questions
			#elsif params[:type] == "self"
				#user = User.find_by_reecher_id(params[:user_id])
				#@Questions = user.questions
			#end	

			if @Questions.size > 0
				@Questions.each do |q|
				  q.posted_solutions.size > 0 ? q[:has_solution] = true : q[:has_solution] = false
				  q.is_stared? ? q[:stared] = true : q[:stared] =false
				end	
			end
			  logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{@Questions.size}"
				render :json => @Questions 
    end


		def show
    		@question = Question.find(params[:id])
    		@solutions = Solution.filter(@question, current_user)
    		@allsolutions = @question.posted_solutions
		    #filter solutions by user id (ie, does user id exist in solutions?)
		    #@allsolutions.each do |sol|
		    #  if sol.users.exists?(current_user)
		    #      @solutions << sol
		    #  end  
		    #end
		    #@solutions = @allsolutions.find_by_uid_exist?
			respond_with @question, @solutions, @allsolutions
		end


		def create		    
		    @user = User.find_by_reecher_id(params[:user_id])
		    @question = Question.new()
		    @question.post = params[:question]
    		@question.posted_by_uid = @user.reecher_id
    		@question.posted_by = @user.full_name
    		@question.ups = 0
    		@question.downs = 0 
	 			@question.Charisma = 5
				if @user.points > @question.Charisma	 
					@question.add_points(@question.Charisma)
					@user.subtract_points(10)
					  if !params[:attached_image].blank? 
    					data = StringIO.new(Base64.decode64(params[:attached_image]))
    					@question.avatar = data
  					end
     			@question.save ? msg = {:status => 200, :question => @question, :message => "Question broadcasted for 10 Charisma Creds! Solutions come from your experts - lend a helping hand in the mean time and get rewarded!"} : msg = {:status => 401, :message => @question.errors}
    		 logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"
    		 render :json => msg
				else
					msg = {:status => 401, :message => "Sorry, you need at least 10 Charisma Creds to ask a Question! Earn some by providing Solutions!"}					    			
        	logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"
        	render :json => msg	
				end

		end

		def mark_question_stared
			@user = User.find_by_reecher_id(params[:user_id])
			@question = Question.find_by_question_id(params[:question_id])
			if params[:stared] == true
				@voting = Voting.new do |v|
  								u.user_id = @user.id
  								u.question_id = @question.id
								end
				@voting.save ? msg = {:status => 200, :message => "Successfully Stared"} : msg = {:status => 401, :message => "Failed!"}
			elsif params[:stared] == false
				@voting = Voting.where(user_id: @user.id, question_id: @question.id)
				@voting.destroy
				@voting.destroyed? ? msg = {:status => 200, :message => "Successfully UnStared"} : msg = {:status => 401, :message => "Failed!"}
			end
			logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"	
			render :json => msg 
		end	


		private

		

		end
	end
end
