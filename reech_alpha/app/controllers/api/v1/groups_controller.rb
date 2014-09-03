module Api
  module V1

    class GroupsController < ApiController
      before_filter :restrict_access
      respond_to :json
      before_filter :set_params, only: :create

      def set_params
        params[:group] = {name: params[:group_name], reecher_id: params[:user_id], member_reecher_ids: [params[:associated_user_id]]}
      end

      def associate_user_to_group
        user = User.find_by_reecher_id(params[:associated_user_id])
        if current_user.friends.include? user
          user.groups = user.groups - current_user.owned_groups + current_user.owned_groups.where(id: params[:group_id])
          msg = {:status => 200, :message => "User is Associated to the  groups",:group_ids=>params[:group_id] }
        else
          msg = {:status => 403, :message => "Asoociate not a friend",:group_ids=>params[:group_id] }
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
