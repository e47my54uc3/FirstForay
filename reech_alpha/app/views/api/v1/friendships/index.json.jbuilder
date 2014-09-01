json.status 200
user = User.find_by_reecher_id(params[:user_id])
#friends = user.friendships.accepted
json.friends_list(user.friends) do |row|
  json.name row.full_name
  json.email row.email
  json.reecherId row.reecher_id
  json.location row.location
  json.image_url row.user_profile.image_url
  json.associated_group_ids row.get_friend_associated_groups(user.reecher_id)
end
groups=Group::reecher_personal_groups params[:user_id]
json.groups groups
