class UsersController < ApplicationController
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save  #&& @user.create_reecher_node
      redirect_to root_url,:notice => "You have been registered successfully.You can now log in."
    else
      flash[:error]=@user.errors.full_messages
      render :action => "new"
    end
  end


 respond_to :json, :xml
  def show
    @user=current_user
  end

  def showconnections
    flash[:notice]
    @user = User.find_by_reecher_id(params[:reecher_id])
		 
	 @all_connections=User.all
  end

	

end
