module Api
	module V1
		class QuestionsController < ApplicationController
		#http_basic_authenticate_with name: "admin", password "secret"
		before_filter :restrict_access
		respond_to :json

		def index
    		respond_with Question.find(:all, :order => 'questions.created_at DESC')
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
		    respond_with Question.new(params[:question])
		    
		 #    @question.posted_by_uid=current_user.reecher_id
		 #    @question.posted_by=current_user.full_name
		 #    @question.ups=0
		 #    @question.downs=0
			# @question.Charisma=5
			# @question.save!
		end


private


		def restrict_access
			authenticate_or_request_with_http_token do |token, options|
			ApiKey.exists?(access_token: token)
			end
		end


		end
	end
end
