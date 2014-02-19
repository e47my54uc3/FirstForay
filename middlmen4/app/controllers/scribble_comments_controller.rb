class ScribbleCommentsController < ApplicationController
	def create
		@commentor=User.find_by_beamer_id(params[:commentor_id_val])
		@comment = ScribbleComment.create(params[:scribble_comment])
		@comment.scribble_id=params[:scribble_id_val]
		@comment.commentor_id=@commentor.beamer_id
		@comment.commentor = "#{@commentor.first_name} #{@commentor.last_name}"
		@comment.ask_charisma=@comment.ask_charisma 
		@comment.linked_user=@comment.linked_user	
		@comment.save
		redirect_to root_url
	end
end
