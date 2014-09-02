module Api
	module V1
		class ApiController < CrudController
		respond_to :json	

			private
			def restrict_access
				unless  ApiKey.exists?(access_token: params[:api_key])
			  		authenticate_or_request_with_http_token do |token, options|
			    		ApiKey.exists?(access_token: token)
			  		end
				end
			end

			def set_user
				@user = User.find_by_reecher_id(params[:user_id])
			end
		end
	end
end

