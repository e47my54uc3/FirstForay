class CategoriesController < CrudController
 def index
 	@categories = Category.search(params[:search], :star => true)
 	render json: @categories
 end
end
