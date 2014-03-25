module Api
	module V1
		class QuestionsController < ApiController
		#http_basic_authenticate_with name: "admin", password "secret"
		before_filter :restrict_access
		#doorkeeper_for :all
		respond_to :json

		def index
				@Questions = Question.filterforuser(params[:user_id])
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
     			if @question.save!
     					msg = {:status => 200, :question => @question, :message => "Question broadcasted for 10 Charisma Creds! Solutions come from your experts - lend a helping hand in the mean time and get rewarded!"}					    			
        			render :json => msg 
      		else
      				msg = {:status => 401, :message => @question.errors}					    			
        			render :json => msg 
      		end
    		
				else
					msg = {:status => 401, :message => "Sorry, you need at least 10 Charisma Creds to ask a Question! Earn some by providing Solutions!"}					    			
        	render :json => msg	
				end
		    ##respond_with Question.new(params[:question])
		 		# @question.posted_by_uid=current_user.reecher_id
				# @question.posted_by=current_user.full_name
		 		# @question.ups=0
		 		# @question.downs=0
				# @question.Charisma=5
				# @question.save!
		end


		private

		

		end
	end
end
