module Api
	module V1
		class QuestionsController < ApiController
		#http_basic_authenticate_with name: "admin", password "secret"
		before_filter :restrict_access
		#doorkeeper_for :all
		respond_to :json

		def index
			@Questions = [] 
			questions_hash = []
			if params[:type] == "feed"
			  @Questions = Question.filterforuser(params[:user_id])
			elsif params[:type] == "stared"
				@Questions = Question.includes(:posted_solutions, :votings).order("created_at DESC").get_stared_questions(params[:user_id])
			elsif params[:type] == "self"
				user = User.find_by_reecher_id(params[:user_id])
				@Questions = user.questions.includes(:posted_solutions, :votings).order("created_at DESC")
			end 

			if @Questions.size > 0
				@Questions.each do |q|
					q_hash = q.attributes
					q.posted_solutions.size > 0 ? q_hash[:has_solution] = true : q_hash[:has_solution] = false
					q.is_stared? ? q_hash[:stared] = true : q_hash[:stared] =false
					q.avatar_file_name != nil ? q_hash[:image_url] = "http://#{request.host_with_port}" + q.avatar_url : q_hash[:image_url] = nil
					questions_hash << q_hash
				end 
			end
				logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{@Questions.size}"
				msg = {:status => 200, :questions => questions_hash }
				render :json => msg 
		end


		def show
				@question = Question.find(params[:id])
				@solutions = Solution.filter(@question, current_user)
				@allsolutions = @question.posted_solutions
				#filter solutions by user id (ie, does user id exist in solutions?)
				#@allsolutions.each do |sol|
				#  if sol.users.exists?(current_user)
				#      @solutions << sol
				#  end  
				#end
				#@solutions = @allsolutions.find_by_uid_exist?
			respond_with @question, @solutions, @allsolutions
		end


		def create        
				@user = User.find_by_reecher_id(params[:user_id])
				@question = Question.new()
				@question.post = params[:question]
				@question.posted_by_uid = @user.reecher_id
				@question.posted_by = @user.full_name
				@question.ups = 0
				@question.downs = 0 
				@question.Charisma = 5
				if @user.points > @question.Charisma   
					@question.add_points(@question.Charisma)
					@user.subtract_points(10)
						if !params[:attached_image].blank? 
							data = StringIO.new(Base64.decode64(params[:attached_image]))
							@question.avatar = data
						end

						# Setting audiens for displaying posetd user details of a question
						if !params[:audien_details].nil?

							if !params[:audien_details][:emails].nil?
								audien_reecher_ids = []
								params[:audien_details][:emails].each do |email|
									user = User.find_by_email(email)
									# If audien is a reecher store his reedher_id in question record
									# Else send an Invitation mail to the audien
									if user.present?
										audien_reecher_ids << user.reecher_id
									else
									  UserMailer.send_invitation_email_for_audien(email, @user).deliver
									end	
								end	
								@question.audien_user_ids = audien_reecher_ids if audien_reecher_ids.size > 0
							end	

							# If the audien is not a reecher and have contact number then send an SMS
							if !params[:audien_details][:phone_numbers].nil?
								client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
								params[:audien_details][:phone_numbers].each do |number|
									sms = client.account.sms.messages.create(
        							from: TWILIO_CONFIG['from'],
        							to: number,
        							body: "#{@user.email} Invited you to answer his question in Reechout.Please Download and Install Reechout app from app store."
      						)
      						logger.debug ">>>>>>>>>Sending sms to #{number} with text #{sms.body}"
								end	
							end	

						end	
					@question.save ? msg = {:status => 200, :question => @question, :message => "Question broadcasted for 10 Charisma Creds! Solutions come from your experts - lend a helping hand in the mean time and get rewarded!"} : msg = {:status => 401, :message => @question.errors}
				 	logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"
				 	render :json => msg
				else
					msg = {:status => 401, :message => "Sorry, you need at least 10 Charisma Credits to ask a Question! Earn some by providing Solutions!"}                   
					logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"
					render :json => msg 
				end

		end

		def mark_question_stared
			@user = User.find_by_reecher_id(params[:user_id])
			@question = Question.find_by_question_id(params[:question_id])
			
			if params[:stared] == "true"
				@voting = Voting.where(user_id: @user.id, question_id: @question.id).first
				if @voting.blank?
				@voting = Voting.new do |v|
									v.user_id = @user.id
									v.question_id = @question.id
								end
				@voting.save ? msg = {:status => 200, :message => "Successfully Stared"} : msg = {:status => 401, :message => "Failed!"}
			 else
				msg = {:status => 200, :message => "Already Stared"}
			 end  
			elsif params[:stared] == "false"
				@voting = Voting.where(user_id: @user.id, question_id: @question.id).first
				if @voting.present?
					@voting.destroy
					@voting.destroyed? ? msg = {:status => 200, :message => "Successfully UnStared"} : msg = {:status => 401, :message => "Failed!"}
				else
					msg = {:status => 200, :message => "Already UnStared"}
				end 
			end
			logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}" 
			render :json => msg 
		end 


		private

		

		end
	end
end
