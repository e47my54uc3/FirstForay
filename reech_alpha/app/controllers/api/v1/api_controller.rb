module Api
	module V1
		class ApiController < ActionController::Base




private
			def restrict_access
				unless  ApiKey.exists?(access_token: params[:api_key])
			  		authenticate_or_request_with_http_token do |token, options|
			    		ApiKey.exists?(access_token: token)
			  		end
				end
			end
		end
	end
end

