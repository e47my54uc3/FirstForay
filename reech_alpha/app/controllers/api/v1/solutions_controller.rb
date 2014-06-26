module Api
	module V1
		class SolutionsController < ApiController
		before_filter :restrict_access
		respond_to :json	

			def create
				@solver = User.find_by_reecher_id(params[:user_id])
				@solution = Solution.new()
				@solution.body = params[:solution]
				@solution.question_id = params[:question_id]
				@solution.solver_id = @solver.reecher_id
				@solution.solver = "#{@solver.first_name} #{@solver.last_name}"
				@solution.ask_charisma = params[:ask_charisma] 

				if !params[:solution_image].blank? 
					data = StringIO.new(Base64.decode64(params[:solution_image]))
					@solution.picture = data
				end

				if !params[:expert_details].nil?
					if !params[:expert_details][:emails].nil?
						# if the expert is in reech network directly link the question 
						# Otherwise send an simple email to him
						params[:expert_details][:emails].each do |email|
							linked_user = User.find_by_email(email)
							if linked_user.present?
								linked_question = LinkedQuestion.where(:user_id => linked_user.reecher_id, :question_id => params[:question_id], :linked_by_uid => @solver.reecher_id)
								if !linked_question.present?
									link_question = LinkedQuestion.new
									link_question.user_id = linked_user.reecher_id
									link_question.question_id = params[:question_id]
									link_question.linked_by_uid = @solver.reecher_id
									link_question.save
								end	
							else
							  
				        begin
                  UserMailer.send_link_question_email(email, @solver).deliver
                rescue Exception => e
                  logger.error e.backtrace.join("\n")
                end
								
							end	
						end	
					end

					if !params[:expert_details][:phone_numbers].nil?
						client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
						params[:expert_details][:phone_numbers].each do |number|
							sms = client.account.sms.messages.create(
        							from: TWILIO_CONFIG['from'],
        							to: number,
        							body: "your friend #{@solver.first_name} #{@user.last_name}  want to solve his friend's question on Reech."
      						)
      						logger.debug ">>>>>>>>>Sending sms to #{number} with text #{sms.body}"
						end
					end	
			 end	
       
        
      
        
				if @solution.save
				    # send push notification to user who posted this question
            qust_details = Question.find_by_question_id(params[:question_id])
            #user_details = User.includes(:questions).where("questions.question_id" =>params[:question_id]) 
            puts "question posted by= #{qust_details.posted_by_uid}"
            if !qust_details.nil?
               check_setting= check_notify_question_when_answered(qust_details.posted_by_uid)
               puts "check_setting==#{check_setting}"
               if check_setting
                #device_details = Device.where("reecher_id=?",user_details[0][:posted_by_uid].to_s)
                device_details=Device.select("device_token,platform").where("reecher_id=?",qust_details.posted_by_uid.to_s)
                puts "device_details==#{device_details.inspect}"
                response_string ="PRSLN,"+ @solution.solver + ","+params[:question_id]+","+Time.now().to_s
                if !device_details.empty? 
                    device_details.each do |d|
                      
                      send_device_notification(d[:device_token].to_s, response_string ,d[:platform].to_s)
                    end  
                end 
               end
             
            end
=begin           
           #Send push notification to those who starred this question
           @voting = Voting.where(question_id: params[:question_id],)
				   if @voting.blank?
            @voting = Voting.new do |v|
            #response_string ="PRSLN,"+ @solution.solver + ","+params[:question_id]
             check_setting= notify_solution_got_highfive(v.user_id)
             if check_setting
              device_details = Device.select("device_token,platform").where("reecher_id=?",qust_details.posted_by_uid.to_s)
              response_string ="HGHFV,"+ @solution.solver + ","+params[:question_id]+"," +Time.now().to_s
              if !device_details.blank?   
                 device_details.each do |d|
                   
                   send_device_notification(d[:device_token].to_s, response_string ,d[:platform].to_s)
                      
                 end
              end
             end
           end
          end
=end				
					msg = {:status => 200, :solution => @solution}
					
				else
					msg = {:status => 400, :message => "Failed"}
				end	
				render :json => msg
			end

			def purchase_solution
				user = User.find_by_reecher_id(params[:user_id])
				solution = Solution.find(params[:solution_id])
				purchased_sl = PurchasedSolution.where(:user_id => user.id, :solution_id => solution.id)
				if purchased_sl.present?
					msg = {:status => 400, :message => "You have Already Purchased this Solution."}
				else	
					if user.points > solution.ask_charisma
						purchased_solution = PurchasedSolution.new
						purchased_solution.user_id = user.id
						purchased_solution.solution_id = solution.id
						purchased_solution.save
						preview_solution = PreviewSolution.find_by_user_id_and_solution_id(user.id, solution.id)
						preview_solution.destroy

						#Add points to solution provider
						solution_provider = User.find_by_reecher_id(solution.solver_id)
						solution_provider.add_points(solution.ask_charisma)

						#Revert back the points to user who post the question
						user.add_points(10)

						msg = {:status => 200, :message => "Success"}
					else
						msg = {:status => 400, :message => "Sorry, you need at least #{solution.ask_charisma} Charisma Credits to purchase this Solution! Earn some by providing Solutions!"}
					end	
				end
				render :json => msg
			end	

			def view_solution
				solution = Solution.find(params[:solution_id])
				solution_owner_profile = User.find_by_reecher_id(solution.solver_id).user_profile
				@solution = solution.attributes
				@solution[:hi5] = solution.votes_for.size
				solution.picture_file_name != nil ? @solution[:image_url] =  solution.picture_original_url : @solution[:image_url] = nil
				solution_owner_profile.picture_file_name != nil ? @solution[:solver_image] =  solution_owner_profile.picture_url : @solution[:solver_image] = nil
			  msg = {:status => 201, :message => "Success", :user_id=>solution_owner_profile.reecher_id}
				msg = {:status => 200, :solution => @solution} 
				render :json => msg
			end	
			
=begin
			def view_all_solutions
				solutions = Solution.find_all_by_question_id(params[:question_id])
				#qust_details =Question.find_by_question_id(params[:question_id])
				logined_user = User.find_by_reecher_id(params[:user_id])
				@solutions = []
				if solutions.size > 0
					solutions.each do |sl|
					  
						solution_attrs = sl.attributes
						
						user = User.find_by_reecher_id(sl.solver_id)
						
						user.user_profile.picture_file_name != nil ? solution_attrs[:solver_image] =  "http://#{request.host_with_port}" + user.user_profile.picture_url : solution_attrs[:solver_image] = nil
						
						sl.picture_file_name != nil ? solution_attrs[:image_url] =  "http://#{request.host_with_port}" + sl.picture_url : solution_attrs[:image_url] = "http://#{request.host_with_port}/"+"no-image.png"
						
						purchased_sl = PurchasedSolution.where(:user_id => logined_user.id, :solution_id => sl.id)
					 
						if purchased_sl.present?  
							solution_attrs[:purchased] = true
						else
							solution_attrs[:purchased] = false	
						end	
						
						@solutions << solution_attrs
					
					end	
				end
				msg = {:status => 200, :solutions => @solutions} 
				logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{@solutions}"

				render :json => msg
			end	

=end
			def preview_solution
				@user = User.find_by_reecher_id(params[:user_id])
				@solution = Solution.find(params[:solution_id])
				@preview_solution = PreviewSolution.where(:user_id => @user.id, :solution_id => @solution.id)
				if @preview_solution.present? 
				  msg = {:status => 400, :message => "You have to purchase this solution."}
				else
					preview_solution = PreviewSolution.new
					preview_solution.user_id = @user.id
					preview_solution.solution_id = @solution.id
					preview_solution.save
					msg = {:status => 200, :solution => @solution}
				end	
				render :json => msg
			end	

			def previewed_solutions
				@user = User.find_by_reecher_id(params[:user_id])
				previewed_solutions = @user.preview_solutions
				solution_ids = []
				if previewed_solutions.size > 0
					previewed_solutions.each do |ps|
						solution_ids << ps.solution_id
					end
				end	
				msg = {:status => 200, :solution_ids => solution_ids}
				logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{solution_ids}"
				render :json => msg
			end	

			def solution_hi5
				solution = Solution.find(params[:solution_id])
				user = User.find_by_reecher_id(params[:user_id])
				solution.liked_by(user)
				@solution = solution.attributes
				@solution[:hi5] = solution.votes_for.size
				solution.picture_file_name != nil ? @solution[:image_url] =  solution.picture_url : @solution[:image_url] = nil
				# send push notification while hi5 solution
				check_setting= notify_solution_got_highfive(solution.solver_id)
               puts "check_setting==#{check_setting}"
               if check_setting
                device_details=Device.select("device_token,platform").where("reecher_id=?",solution.solver_id.to_s)
                response_string ="HGHFV,"+ user.full_name + "," + params[:solution_id] +","+Time.now().to_s
                if !device_details.empty? 
                    device_details.each do |d|
                      send_device_notification(d[:device_token].to_s, response_string ,d[:platform].to_s)
                    end  
                end 
               end
				
				msg = {:status => 200, :solution => @solution}
				render :json => msg
				
				
			end	
      
       def get_solution_details
        sol_id = params[:solution_id]
        sol_details = Solution.find_by_question_id(sol_id)
        msg = {:status => 200, :solution_details => sol_details}
        render :json =>msg 
        
       end
     
       
       def question_details_with_solutions
        solutions = Solution.find_all_by_question_id(params[:question_id])
        qust_details =Question.find_by_question_id(params[:question_id])
        question_owner = User.find_by_reecher_id(qust_details [:posted_by_uid])
        question_owner_profile = question_owner.user_profile
        qust_details.is_stared? ? qust_details[:stared] = true : qust_details[:stared] =false
        qust_details[:owner_location] = question_owner_profile.location
        qust_details[:avatar_file_name] != nil ? qust_details[:image_url] =  qust_details.avatar_original_url : qust_details[:image_url] = nil
        question_owner_profile.picture_file_name != nil ? qust_details[:owner_image] = question_owner_profile.thumb_picture_url : qust_details[:owner_image] = nil
        logined_user = User.find_by_reecher_id(params[:user_id])
        @solutions = []
        if solutions.size > 0
          solutions.each do |sl|
            solution_attrs = sl.attributes
            user = User.find_by_reecher_id(sl.solver_id)
            user.user_profile.picture_file_name != nil ? solution_attrs[:solver_image] =  user.user_profile.thumb_picture_url : solution_attrs[:solver_image] = nil
            sl.picture_file_name != nil ? solution_attrs[:image_url] =  sl.picture_url : solution_attrs[:image_url] = nil
=begin           
          if !sl.picture_file_name.blank?
            width=  Paperclip::Geometry.from_file(sl.picture.path(:medium)).width
            height=  Paperclip::Geometry.from_file(sl.picture.path(:medium)).height
            solution_attrs[:image_width] = width
            solution_attrs[:image_height] = height
          end
=end           
          purchased_sl = PurchasedSolution.where(:user_id => logined_user.id, :solution_id => sl.id)
          if purchased_sl.present?
            solution_attrs[:purchased] = true
          else
            solution_attrs[:purchased] = false  
          end 
            @solutions << solution_attrs
          end 
          
          
          
          sorted_sol = []
          
          @solutions.each do |sol|
            
            if sol[:purchased]
            sorted_sol << sol
            end
            
          end
          @solutions.each do |sol|
            
            if !sol[:purchased]
            sorted_sol << sol
            end
          end  
          
          puts "@solutions before123==#{sorted_sol}"
         
          #@solutions = @solutions.sort_by{ |arr| arr.purchased  } if !@solutions.blank?
          
         # puts "@solutions after==#{@solutions.inspect}"
        end
        msg = {:status => 200, :qust_details=>qust_details ,:solutions => sorted_sol} 
        logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{sorted_sol}"
        render :json => msg
      end  
        
      def post_solution_with_image
        
        @solver = User.find_by_reecher_id(params[:user_id])
        @solution = Solution.new()
        @solution.body = params[:solution]
        @solution.question_id = params[:question_id]
        @solution.solver_id = @solver.reecher_id
        @solution.solver = "#{@solver.first_name} #{@solver.last_name}"
        @solution.ask_charisma = params[:ask_charisma] 

        if !params[:file].blank? 
          @solution.picture = params[:file]
        end

        if !params[:expert_details].nil?
          if !params[:expert_details][:emails].nil?
            # if the expert is in reech network directly link the question 
            # Otherwise send an simple email to him
            params[:expert_details][:emails].each do |email|
              linked_user = User.find_by_email(email)
              if linked_user.present?
                linked_question = LinkedQuestion.where(:user_id => linked_user.reecher_id, :question_id => params[:question_id], :linked_by_uid => @solver.reecher_id)
                if !linked_question.present?
                  link_question = LinkedQuestion.new
                  link_question.user_id = linked_user.reecher_id
                  link_question.question_id = params[:question_id]
                  link_question.linked_by_uid = @solver.reecher_id
                  link_question.save
                end 
              else
                   begin
                      UserMailer.send_link_question_email(email, @solver).deliver
                    rescue Exception => e
                      logger.error e.backtrace.join("\n")
                    end
                
              end 
            end 
          end

          if !params[:expert_details][:phone_numbers].nil?
            client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
            params[:expert_details][:phone_numbers].each do |number|
              sms = client.account.sms.messages.create(
                      from: TWILIO_CONFIG['from'],
                      to: number,
                      body: "your friend #{@solver.first_name} #{@user.last_name}  want to solve his friend's question on Reech."
                  )
                  logger.debug ">>>>>>>>>Sending sms to #{number} with text #{sms.body}"
            end
          end 
       end  
       
        
      
        
        if @solution.save
            # send push notification to user who posted this question
            qust_details = Question.find_by_question_id(params[:question_id])
            #user_details = User.includes(:questions).where("questions.question_id" =>params[:question_id]) 
            puts "question posted by= #{qust_details.posted_by_uid}"
            if !qust_details.nil?
               check_setting= check_notify_question_when_answered(qust_details.posted_by_uid)
               puts "check_setting==#{check_setting}"
               if check_setting
                #device_details = Device.where("reecher_id=?",user_details[0][:posted_by_uid].to_s)
              
                device_details=Device.select("device_token,platform").where("reecher_id=?",qust_details.posted_by_uid.to_s)
               puts "device_details==#{device_details.inspect}"
                response_string ="PRSLN,"+ @solution.solver + ","+params[:question_id]+","+Time.now().to_s
                
                if !device_details.empty? 
                    device_details.each do |d|
                      
                   # begin
                      send_device_notification(d[:device_token].to_s, response_string ,d[:platform].to_s)
                    #rescue Exception => e
                    #  logger.error e.backtrace.join("\n")
                    #end
                    end  
                end 
               end
             
            end
=begin           
           # Send push notification to those who starred this question
           @voting = Voting.where(question_id: params[:question_id])
           if @voting.blank?
            @voting = Voting.new do |v|
            response_string ="PRSLN,"+ @solution.solver + ","+params[:question_id]
             check_setting= notify_solution_got_highfive(v.user_id)
             if check_setting
              device_details = Device.select("device_token,platform").where("reecher_id=?",qust_details.posted_by_uid.to_s)
              response_string ="HGHFV,"+ @solution.solver + ","+params[:question_id]+"," +Time.now().to_s
              if !device_details.blank?   
                 device_details.each do |d|
                    begin
                      send_device_notification(d[:device_token].to_s, response_string ,d[:platform].to_s)
                    rescue Exception => e
                      logger.error e.backtrace.join("\n")
                    end
                 end
              end
             end
           end
          end
=end        
          msg = {:status => 200, :solution => @solution}
          
        else
          msg = {:status => 400, :message => "Failed"}
        end 
        render :json => msg
        
      end    
        
		end
	end
end			