module Api
	module V1
		class QuestionsController < ApiController
		#http_basic_authenticate_with name: "admin", password "secret"
		before_filter :restrict_access , :except =>[:index,:send_apns_notification,:send_gcm_notification]
		#doorkeeper_for :all
		respond_to :json

		def index
			@Questions = [] 
			questions_hash = []
			if params[:type] == "feed"
			  @Questions = Question.filterforuser(params[:user_id])
			elsif params[:type] == "stared"
				#@Questions = Question.includes(:posted_solutions, :votings).order("created_at DESC").get_stared_questions(params[:user_id])
				@Questions = Question.includes(:votings).order("created_at DESC").get_stared_questions(params[:user_id])
				elsif params[:type] == "self"
				user = User.find_by_reecher_id(params[:user_id])
				@Questions = user.questions.includes(:posted_solutions, :votings).order("created_at DESC")
			end 
      
     
      
			if @Questions.size > 0
			  purchasedSolutionId =PurchasedSolution.pluck(:solution_id)			  
			 @Questions.each do |q|
				  q_hash = q.attributes
				  puts "q.posted_by_uid==#{q.posted_by_uid}"
					question_owner = User.find_by_reecher_id(q.posted_by_uid)
					puts "question_owner==#{question_owner}"
					question_owner_profile = question_owner.user_profile
					solutions = Solution.find_all_by_question_id(q.question_id)
					#solutions = solutions.map!(&:id).to_s
					solutions = solutions.collect!{|i| (i.id).to_s}					
					has_solution= purchasedSolutionId & solutions
					has_solution.size > 0 ? q_hash[:has_solution] = true : q_hash[:has_solution] = false
					
					q.is_stared? ? q_hash[:stared] = true : q_hash[:stared] =false
					q.avatar_file_name != nil ? q_hash[:image_url] = "http://#{request.host_with_port}" + q.avatar_url : q_hash[:image_url] = nil
					
				#	image_size123=Paperclip::Geometry.from_file(q_hash[:image_url])
					
				#	geo = Paperclip::Geometry.from_file(avatar.to_file(:medium))
          #geo= Paperclip::Geometry.from_file(q.avatar.path(:original)).to_s
         
          #geometry = Paperclip::Geometry.from_file("data.jpeg")
          #puts "geometry2312321321-=============#{geometry}"
=begin
					if !q.avatar_file_name.blank?
				    width=	Paperclip::Geometry.from_file(q.avatar.path(:medium)).width
            height=  Paperclip::Geometry.from_file(q.avatar.path(:medium)).height
				    q_hash[:image_width] = width
				    q_hash[:image_height] = height
					end
=end
					q_hash[:owner_location] = question_owner_profile.location
					question_owner_profile.picture_file_name != nil ? q_hash[:owner_image] = "http://#{request.host_with_port}" + question_owner_profile.picture_url : q_hash[:owner_image] = nil
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
				#if sol.users.exists?(current_user)
				#@solutions << sol
				#end  
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
							if !params[:audien_details][:emails].empty?
								audien_reecher_ids = []
								params[:audien_details][:emails].each do |email|
									user = User.find_by_email(email)
									# If audien is a reecher store his reedher_id in question record
									# Else send an Invitation mail to the audien
									if user.present?
										audien_reecher_ids << user.reecher_id
									else
									  #UserMailer.send_invitation_email_for_audien(email, @user).deliver
puts "Just trying to send a mail"  # please remove it
									end	
								end	
								@question.audien_user_ids = audien_reecher_ids if audien_reecher_ids.size > 0
							end	

							# If the audien is not a reecher and have contact number then send an SMS
							if !params[:audien_details][:phone_numbers].empty? 
								client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
								params[:audien_details][:phone_numbers].each do |number|
=begin									
									sms = client.account.sms.messages.create(
        							from: TWILIO_CONFIG['from'],
        							to: number,
        							body: "your friend #{@user.first_name} #{@user.last_name} needs your help answering a question on Reech. Signup Reech to give help."
      						)
      						logger.debug ">>>>>>>>>Sending sms to #{number} with text #{sms.body}"
=end				
								end	
							end	
							
							if !params[:audien_details][:reecher_ids].empty? 
							   params[:audien_details][:reecher_ids].each do |reech_id|
							   user = User.find_by_reecher_id(reech_id)
                 UserMailer.send_invitation_email_for_audien(user.email, user).deliver
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

		def linked_questions
			user = User.find_by_reecher_id(params[:user_id])
			if user.blank?
			  msg = { :status => 401, :message => "Failure!"}
        render :json => msg
			end
			linked_questions = user.linked_questions
		  if !linked_questions.empty? &&  linked_questions.size >0
    			linked_questions_ary = []
    			 purchasedSolutionId =PurchasedSolution.pluck(:solution_id)
    				linked_questions.each do |lq|
    				 question = Question.find_by_question_id(lq.question_id) 
    				 solutions = Solution.find_all_by_question_id(params[:question_id])
    				 solutions = solutions.collect!{|i| (i.id).to_s}       					
    					question_owner = User.find_by_reecher_id(question.posted_by_uid)
    					question_owner_profile = question_owner.user_profile
    					q_hash = question.attributes
    					has_solution= purchasedSolutionId & solutions
    					
    					has_solution.size > 0 ? q_hash[:has_solution] = true : q_hash[:has_solution] = false
    					question.is_stared? ? q_hash[:stared] = true : q_hash[:stared] =false
    					question.avatar_file_name != nil ? q_hash[:image_url] = "http://#{request.host_with_port}" + question.avatar_url : q_hash[:image_url] = nil
    					q_hash[:owner_location] = question_owner_profile.location
    					question_owner_profile.picture_file_name != nil ? q_hash[:owner_image] = "http://#{request.host_with_port}" + question_owner_profile.picture_url : q_hash[:owner_image] = nil
    					
          		if !question.avatar_file_name.blank?
              width=  Paperclip::Geometry.from_file(question.avatar.path(:medium)).width
              height=  Paperclip::Geometry.from_file(question.avatar.path(:medium)).height
              q_hash[:image_width] = width
              q_hash[:image_height] = height
              end
    					
    					linked_questions_ary << q_hash
    				end	
    			
    			msg = {:status => 200, :questions => linked_questions_ary}
    			render :json => msg
	    else
	   
	    msg = { :status => 401, :message => "linked Question Not Available!"}
      render :json => msg
	       
	    end	
	    
 		end	
    
    def link_questions_to_expert
      user = User.find_by_reecher_id(params[:user_id])
      if !user.blank?
        if !params[:referral_details][:email_ids].blank?
           params[:referral_details][:email_ids].each do |email|
            LinkedQuestion.create(:user_id =>'',:question_id=>params[:question_id],:linked_by_uid=>params[:user_id],:email_id=>email,:phone_no =>'')
              UserMailer.send_link_question_email(email, user).deliver
           end
        end
        if !params[:referral_details][:phone_no].blank?
          client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
           params[:referral_details][:phone_no].each do |phone|
            LinkedQuestion.create(:user_id =>'',:question_id=>params[:question_id],:linked_by_uid=>params[:user_id],:email_id=>'',:phone_no =>phone)
=begin           
            sms = client.account.sms.messages.create(
                      from: TWILIO_CONFIG['from'],
                      to: phone,
                      body: "your friend #{user.first_name} #{user.last_name}  want to link this question i.e #{params[:question_id]} to you on Reech."
                  )
                  logger.debug ">>>>>>>>>Sending sms to #{phone} with text #{sms.body}"
=end
          end
        end
        if !params[:referral_details][:reecher_ids].blank?
          params[:referral_details][:reecher_ids].each do |reech_id|
          LinkedQuestion.create(:user_id =>reech_id,:question_id=>params[:question_id],:linked_by_uid=>params[:user_id],:email_id=>'',:phone_no =>'')
          check_setting= notify_when_my_stared_question_get_answer(reech_id)
         if check_setting
           user_details = User.where("users.reecher_id" =>reech_id) 
             if !user_details.blank?
               device_details = Device.find_by_reecher_id(user_details[0][:reecher_id])
                if !device_details.blank?
                  notify_string ="LINKED,"+user.full_name + ","+ params[:question_id]
                  send_device_notification(device_details[:device_token], notify_string ,user_details[0][:platform])
               end
             end
         end     
          end
        end
      # end of outer  if loop
     end
      msg = { :status => 200, :message => "success"}
      render :json =>msg 
    end
  
  
  
    def send_gcm_notification
        destination = ["APA91bFbYwmetpiv96X1c52tV_sOpT9ZkAZlDyqk1AWKXvwe7bjVUJJ8QwsGB4kkHFt-JiIfIrGh7ScM6ZrTdBe5GCAXkwzncQ4ynAk9zcnVkP5OvYhwVriVcsdgrzfFqZsd4vu6CLoCGMerOP0BH1evR8YqtjcgkA"]#params[:device_token]
        #data1 = {:msg => "Hello Vijay"}
        # must be an hash with all values you want inside you notification
        # options1 = {:collapse_key => "placar_score_global", :time_to_live => 3600, :delay_while_idle => true}
        # options for the notification
        #n1 = GCM.Notification(destination, data1, options1)
        #data = {:alert => "Hello Android!!!" }
        # GCM.send_notification( destination,{"key" =>"HELLO WORLD"} )
        #GCM.send_notification( destination , data1, {:collapse_key => "score update", :time_to_live => 3600, :delay_while_idle => true})
      #  msg = { :status => 200, :message => "success"}
       # render :json =>msg
       message_options = {
    
     # optional parameters below.  Read the docs here: http://developer.android.com/guide/google/gcm/gcm.html#send-msg
  :collapse_key => "foobar",
  :data => { :score => "3x1" },
  :delay_while_idle => true,
  :time_to_live => 1,
  :registration_ids => destination
}


  puts "send notify=#{message_options}"
  response = SpeedyGCM::API.send_notification(message_options)
  puts "after send notify=#{response.inspect}"  
  #puts "response=#{response[:code] }"  # some http response code like 200
 # puts "response1=#{response[:data]}" 
  
  msg = { :status => 200, :code => response[:code],:data=>response[:data]}
  render :json =>msg 
       
    end
     
     
     
  #  End for class, modules
		end
	end
end
