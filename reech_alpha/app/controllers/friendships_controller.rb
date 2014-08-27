class FriendshipsController < ApplicationController

  def req
    @friend = User.find_by_reecher_id(params[:reecher_id])
    unless @friend.nil?
      if Friendship.request(current_user, @friend)
        flash[:notice] = "Friendship with #{@friend.full_name} requested"
      else
        flash[:notice] = "Friendship with #{@friend.full_name} cannot be requested"
      end
    end
    redirect_to :back
  end

  def accept
    @friend = User.find_by_reecher_id(params[:reecher_id])
    unless @friend.nil?
      if Friendship.accept(current_user, @friend)
        flash[:notice] = "Friendship with #{@friend.full_name} accepted"
      else
        flash[:notice] = "Friendship with #{@friend.full_name} cannot be accepted"
      end
    end
    redirect_to :back
  end

  def reject
    @friend = User.find_by_reecher_id(params[:reecher_id])
    unless @friend.nil?a
      if Friendship.reject(current_user, @friend)
        flash[:notice] = "Friendship with #{@friend.full_name} rejected"
      else
        flash[:notice] = "Friendship with #{@friend.full_name} cannot be rejected"
      end
    end
    redirect_to :back
  end

end
