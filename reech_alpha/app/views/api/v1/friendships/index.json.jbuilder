json.status 200
json.friends_list(current_user.friends, :name, :email, :reecherId, :location, :image_url)
groups = Group::reecher_personal_groups params[:user_id]
json.groups current_user.owned_groups
json.associated_group_ids (current_user.groups - current_user.owned_groups).collect(&:id)
