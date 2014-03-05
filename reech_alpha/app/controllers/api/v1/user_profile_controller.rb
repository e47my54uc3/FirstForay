module Api
	module V1
		class UserProfileController < ApplicationController
  			respond_to :json

  			before_filter :get_user

		  	def index
		    	if current_user.nil?
		    		respond_with "Must be logged in"
		    	else
		    		@profile = @user.user_profile
			 		@badge = @user.badges
			 		respond_with @profile
			 	end
		  	end

		  	# POST /:username/profile/:reecher_id
		  	def update
		  	end


		end
	end
end

