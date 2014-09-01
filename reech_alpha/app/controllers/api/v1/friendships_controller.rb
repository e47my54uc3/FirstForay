module Api
	module V1
		class FriendshipsController < ApiController
		before_filter :restrict_access
		respond_to :json

			def index		
				render "index.json.jbuilder"
			end
      #END 
      
      
		end
	end   
end