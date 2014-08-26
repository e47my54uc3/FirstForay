class CategoriesController < CrudController
 def index
 	@categories = Category.search(params[:search])
 	render json: @categories
 end
end
