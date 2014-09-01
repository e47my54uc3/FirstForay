module Api
  module V1
    class CategoriesController < ApiController
      before_filter :restrict_access
      respond_to :json
      # GET /categories
      # GET /categories.json
      def index        
        render "index.json.jbuilder"
      end    
      
    end
 end
end
