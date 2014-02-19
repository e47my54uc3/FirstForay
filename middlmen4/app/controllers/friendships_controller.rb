class FriendshipsController < ApplicationController

  def req
    @user = current_user
    @friend = User.find_by_beamer_id(params[:beamer_id])
    unless @friend.nil?
      if Friendship.request(@user, @friend)
        flash[:notice] = "Friendship with #{@friend.full_name} requested"
      else
        flash[:notice] = "Friendship with #{@friend.full_name} cannot be requested"
      end
    end
    redirect_to :back
  end

  def accept
    @user = current_user
    @friend = User.find_by_beamer_id(params[:beamer_id])
    unless @friend.nil?
      if Friendship.accept(@user, @friend)
        flash[:notice] = "Friendship with #{@friend.full_name} accepted"
      else
        flash[:notice] = "Friendship with #{@friend.full_name} cannot be accepted"
      end
    end
    redirect_to :back
  end

  def reject
    @user = current_user
    @friend = User.find_by_beamer_id(params[:beamer_id])
    unless @friend.nil?
      if Friendship.reject(@user, @friend)
        flash[:notice] = "Friendship with #{@friend.full_name} rejected"
      else
        flash[:notice] = "Friendship with #{@friend.full_name} cannot be rejected"
      end
    end
    redirect_to :back
  end

end
