status 200
questions @questions do |question|
	pqtfs = PostQuestionToFriend.where("question_id = ?", q.question_id).pluck(:friend_reecher_id)
	
	owner_purchased_solutions = PurchasedSolution.where(user_id: q.user. solution_id => Solution.where(solver_id: @user, question_id: q)).pluck(:solution_id)

	if(!owner_purchased_solutions.blank? || (( @user ==  q.posted_by_uid) || q.is_public))
		question_referee q.user.full_name
		no_profile_pic false
	elsif(!pqtfs.blank? && (pqtfs.include? user_id))
		question_referee q.user.full_name
		no_profile_pic false
	else
		question_referee = "Friend"
        no_profile_pic = true
	end

	owner_purchased_solutions = PurchasedSolution.where(user_id: q.user. solution_id => Solution.where(question_id: q)).pluck(:user_id)

	if !owner_purchased_blank?
		has_solution = true
	else
		has_solution = false
	end

	q.is_stared? ? (stared true) : (stared false)
	q.avatar_file_name != nil ? (image_url q.avatar_url) : (image_url nil)
	if !q.avatar_file_name.blank?
		avatar_geo=((q.avatar_geometry).to_s).split('x') 	
		image_width avatar_geo[0]	
		image_height avatar_geo[1] 	
	end

	owner_location q.user.user_profile.location
	q.user.user_profile.picture_file_name != nil ? (owner_image q.user.user_profile.thumb_picture_url) : owner_image nil
end