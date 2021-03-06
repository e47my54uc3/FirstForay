# Use this hook to configure merit parameters
Merit.setup do |config|
  # Check rules on each request or in background
  # config.checks_on_each_request = true

  # Define ORM. Could be :active_record (default) and :mongo_mapper and :mongoid
  # config.orm = :active_record

  # Define :user_model_name. This model will be used to grand badge if no :to option is given. Default is "User".
  # config.user_model_name = "User"

  # Define :current_user_method. Similar to previous option. It will be used to retrieve :user_model_name object if no :to option is given. Default is "current_#{user_model_name.downcase}".
  # config.current_user_method = "current_user"
end

# Create application badges (uses https://github.com/norman/ambry)
 Merit::Badge.create!({
   id: 1,
   name: "observer",
	description: "unconfirmed account observing user"
 })

 Merit::Badge.create!({
   id: 2,
   name: "thinker",
	description: "started seeking answers to questions"
 })

 Merit::Badge.create!({
   id: 3,
   name: "philosopher",
	description: "asking questions and providing solutions"
 })

 Merit::Badge.create!({
   id: 4,
   name: "master",
	description: "asks the right questions, gives the needed solutions"
 })
