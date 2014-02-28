object @user

attributes :first_name, :last_name, :omniauth_data

node :full_name do |user|
	[user.first_name, user.last_name].join(" ")
end
