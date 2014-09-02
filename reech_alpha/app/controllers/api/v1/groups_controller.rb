module Api
  module V1

    class GroupsController < ApiController
      before_filter :restrict_access 
      respond_to :json
      before_filter :set_params, only: :create
      
      def set_params
        params[controller_name.singularize] = {name: params[:group_name], reecher_id: params[:user_id]}
      end
      def associate_user_to_group
        group = Group.find(params[:group_id]) 
        if group
          group.members << current_user unless self.users.include?(current_user)
          msg = {:status => 200, :message => "User associated to the #{group.name} Group." }  
        else
          msg = {:status => 404, :message => "Group not found." }  
        end
        render json: msg
      end    

      def reecher_personal_groups
        msg = {:status => 200, :groups => current_user.owned_groups }            
        render :json => msg   
      end


    end


  end
end
