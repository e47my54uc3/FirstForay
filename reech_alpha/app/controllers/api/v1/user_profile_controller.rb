module Api
	module V1
		class UserProfileController < ApiController
		respond_to :json
  			
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

		  	def changepass
     		 @user = User.find_by_reecher_id(params[:user_id])
      	     @pass = params[:password]
      	     if !@user.nil?
      	     	if @pass.length < 8
      	     		msg = {:status => 400, :message => "password must be at least 8 characters"}
          			render :json => msg
      	     	else
					@user.password = @pass
	        		@user.password_confirmation = @pass
	        		@user.save!
	        			msg = {:status => 200, :message => "success"}
	          			render :json => msg
        		end
        	else
        			msg = {:status => 400, :message => "Failed"}
          			render :json => msg   # note, no :location or :status options
        	end
        	end



		  	def showconnections
        		@user=User.find_by_reecher_id(params[:user_id])
        		@all_connections = @user.friends.find(:all, :select => "first_name, last_name, email,friend_reecher_id")
        		if !@all_connections.nil?
        			msg = {:status=> 200, :message => @all_connections}
        			render :json => msg
        		else
        			render :json => "Filed"
        		end
      		end

		end
	end
end

