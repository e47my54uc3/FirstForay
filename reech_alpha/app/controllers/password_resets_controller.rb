class PasswordResetsController < ApplicationController
	before_filter :load_user_using_persistence_token, :only => [ :edit, :update ]
	layout false

	def new
	end

	def create
		@user = User.find_by_email(params[:email])
		if @user
			@user.deliver_password_reset_instructions!
			flash[:notice] = "Instructions to reset your password have been emailed to you"
			redirect_to root_path
		else
			flash.now[:error] = "No user was found with email address #{params[:email]}"
			render :action => :new
		end
	end

	def edit
	end

	def update
		@user.password = params[:password]
		# Only if your are using password confirmation
		@user.password_confirmation = params[:password]

		# Use @user.save_without_session_maintenance instead if you
		# don't want the user to be signed in automatically.
		if @user.save_without_session_maintenance(:validate => false)
			flash[:success] = "Your password was successfully updated"
			redirect_to root_url
		else
			render :action => :edit
		end
	end


	private

	def load_user_using_persistence_token
		@user = User.find_by_persistence_token(params[:id])
		unless @user
			flash[:error] = "We're sorry, but we could not locate your account"
			redirect_to root_url
		end
	end
end
