module Api
	module V1
		class ApiController < CrudController
		respond_to :json	
     


private
			def restrict_access
				render :status => 401, :json => {error: "Not authenticated"} unless check_auth
			end

			def check_auth
				unless @current_user 
				  key = ApiKey.find_by_access_token_and_user_id(params[:api_key], params[:user_id])
				  @current_user = key ? User.find_by_reecher_id(params[:user_id]) : nil 
				end
			end

			def current_user
				@current_user
			end
			
			 
			
		end
	end
end

