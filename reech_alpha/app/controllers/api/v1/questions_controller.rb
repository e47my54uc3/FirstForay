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
        #@Questions = Question.includes(:votings).order("created_at DESC").get_stared_questions(params[:user_id])
        user = User.find_by_reecher_id(params[:user_id])
        question_ids = Voting.select("question_id").where("user_id = ?", user.id) unless user.blank?  
        #puts "question_ids==#{question_ids.inspect}"
        question_ids = question_ids.map{|q| q.question_id}
        @Questions = Question.where("id in (?)", question_ids).order("created_at DESC")  unless user.blank?  
            
        elsif params[:type] == "self"
        user = User.find_by_reecher_id(params[:user_id])
        @Questions = user.questions.includes(:solutions, :votings).order("created_at DESC")
        # question which whose solution is purchased.
        my_purchases_solid = PurchasedSolution.select(:solution_id).where("user_id = ?", user.id) 
        quest_hash =[]
        my_purchases_solid.each do |sid|
        qust_purc_sol=Question.joins(:solutions)
                   .select("questions.*,solutions.id as sol_id,solutions.question_id as sol_question_id")
                   .where("solutions.id = ?", sid.solution_id)
         quest_hash.push(qust_purc_sol[0][:id])
        end
        my_quest= @Questions.map{|q| q.id}
        merge_question = quest_hash + my_quest
        my_all_question = merge_question.sort
        @Questions = Question.where("id in (?)", my_all_question).order("created_at DESC")
        
      end 
      
     
      #referred_friend_ids = PostQuestionToFriend::get_referred_friend_ids current_user.reecher_id
      #puts "referred_friend_ids==#{referred_friend_ids}"
      
      if @Questions.size > 0
        purchasedSolutionId =PurchasedSolution.pluck(:solution_id)        
        @Questions.each do |q|
          q_hash = q.attributes
          
          question_owner = User.find_by_reecher_id(q.posted_by_uid)
          
          question_owner_profile = question_owner.user_profile
          
          solutions = Solution.find_all_by_question_id(q.question_id)
          #solutions = solutions.map!(&:id).to_s
          solutions = solutions.collect!{|i| (i.id).to_s}   
          user_who_purchases_sol = PurchasedSolution.select(:user_id).where(:solution_id =>solutions) if !solutions.blank?
          #has_solution= purchasedSolutionId & solutions
          if !user_who_purchases_sol.blank?
            user_who_purchases_sol = user_who_purchases_sol.collect!{|i| (i.user_id)} 
            if user_who_purchases_sol.include? (question_owner.id).to_s
            q_hash[:has_solution] = true
            else
            q_hash[:has_solution] = false 
            end 
          else
            q_hash[:has_solution] = false    
          end
          #has_solution.size > 0 ? q_hash[:has_solution] = true : q_hash[:has_solution] = false
          q.is_stared? ? q_hash[:stared] = true : q_hash[:stared] =false
          q.avatar_file_name != nil ? q_hash[:image_url] =   q.avatar_url : q_hash[:image_url] = nil
          
          #image_size123=Paperclip::Geometry.from_file(q_hash[:image_url])
          
          #geo = Paperclip::Geometry.from_file(avatar.to_file(:medium))
          #geo= Paperclip::Geometry.from_file(q.avatar.path(:original)).to_s
         
          #geometry = Paperclip::Geometry.from_file("data.jpeg")
          #puts "geometry2312321321-=============#{geometry}"
=begin          
          if !q.avatar_file_name.blank?
            width=  Paperclip::Geometry.from_file(q.avatar.path(:medium)).width
            height= Paperclip::Geometry.from_file(q.avatar.path(:medium)).height
            q_hash[:image_width] = width
            q_hash[:image_height] = height
          end
=end
          q_hash[:owner_location] = question_owner_profile.location
          question_owner_profile.picture_file_name != nil ? q_hash[:owner_image] =   question_owner_profile.thumb_picture_url : q_hash[:owner_image] = nil
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
        @question.category_id = params[:category_id]
        if @user.points > @question.Charisma   
          @question.add_points(@question.Charisma)
          @user.subtract_points(10)
            if !params[:attached_image].blank? 
              data = StringIO.new(Base64.decode64(params[:attached_image]))
              @question.avatar = data
              
            end
          # Setting audiens for displaying posetd user details of a question
          if params[:audien_details].class == 'String' 
            params[:audien_details] = JSON.parse(params[:audien_details])
            if !params[:audien_details].nil?
              if params[:audien_details].has_key?("emails")             
              if !params[:audien_details][:emails].empty?
                audien_reecher_ids = []
                 params[:audien_details][:emails].each do |email|
                  user = User.find_by_email(email)
                  # If audien is a reecher store his reedher_id in question record
                  # Else send an Invitation mail to the audien
                  if user.present?
                    audien_reecher_ids << user.reecher_id
                  else
                  begin
                    UserMailer.send_question_details_to_audien(email, @user).deliver
                  rescue Exception => e
                    logger.error e.backtrace.join("\n")
                  end
                    
                  end 
                end 
                @question.audien_user_ids = audien_reecher_ids if audien_reecher_ids.size > 0
              end 
            end
              # If the audien is not a reecher and have contact number then send an SMS
              if params[:audien_details].has_key?("phone_numbers")     
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
             end
             if params[:audien_details].has_key?("reecher_ids") 
              if !params[:audien_details][:reecher_ids].empty? 
                 params[:audien_details][:reecher_ids].each do |reech_id|
                 user = User.find_by_reecher_id(reech_id)
                 PostQuestionToFriend.create(:user_id =>@user.reecher_id ,:friend_reecher_id =>user.reecher_id)
                    begin
                     UserMailer.send_question_details_to_audien(user.email, user).deliver 
                    rescue Exception => e
                    logger.error e.backtrace.join("\n")
                    end
                                 
                end 
                
              end
            end 
            end 
              

            end 
             if @question.save
             catgory = Category.find(@question.category_id)
             @question[:category_name] = catgory.title
             msg = {:status => 200, :question => @question, :message => "Question broadcasted for 10 Charisma Creds! Solutions come from your experts - lend a helping hand in the mean time and get rewarded!"} 
             else 
               msg = {:status => 401, :message => @question.errors}
             end
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
              question.avatar_file_name != nil ? q_hash[:image_url] =   question.avatar_url : q_hash[:image_url] = nil
              q_hash[:owner_location] = question_owner_profile.location
              question_owner_profile.picture_file_name != nil ? q_hash[:owner_image] =   question_owner_profile.picture_url : q_hash[:owner_image] = nil
              
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
             @linkquest = LinkedQuestion.new()
             @linkquest.user_id =''
             @linkquest.question_id = params[:question_id]
             @linkquest.linked_by_uid = params[:question_id]
             @linkquest.email_id = email
             @linkquest.phone_no = ''
             @linkquest.save
             #@rand_has_key = random_key_generator(Time.now)
             rand_str = (('A'..'Z').to_a + (0..9).to_a)
             token = (0...32).map { |n| rand_str.sample }.join
             referral_code = (0...8).map { |n| rand_str.sample }.join
             validity= 15.days.from_now
             tries = 0
             InviteUser.create(:linked_question_id=>@linkquest.id,:token=>token,:referral_code=>referral_code,:token_validity_time =>validity)     
             UserInvitationWithQuestionDetails.send_linked_question_details(email, user,token,referral_code,params[:question_id]).deliver
             #rescue Errono::ECONNRESET => e
             
           end
        end
        if !params[:referral_details][:phone_no].blank?
          client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
           params[:referral_details][:phone_no].each do |phone|
            LinkedQuestion.create(:user_id =>'',:question_id=>params[:question_id],:linked_by_uid=>params[:user_id],:email_id=>'',:phone_no =>phone)
            sms = client.account.sms.messages.create(
                      from: TWILIO_CONFIG['from'],
                      to: phone,
                      body: "your friend #{user.first_name} #{user.last_name}  want to link this question i.e #{params[:question_id]} to you on Reech."
                  )
                  logger.debug ">>>>>>>>>Sending sms to #{phone} with text #{sms.body}"
          end
        end
        if !params[:referral_details][:reecher_ids].blank?
          params[:referral_details][:reecher_ids].each do |reech_id|
          LinkedQuestion.create(:user_id =>reech_id,:question_id=>params[:question_id],:linked_by_uid=>params[:user_id],:email_id=>'',:phone_no =>'')
          check_setting= notify_linked_to_question(reech_id)
          if check_setting
           user_details = User.where("users.reecher_id" =>reech_id) 
             if !user_details.blank?
               device_details = Device.where(:reecher_id=>user_details[0][:reecher_id])
               puts "device_details==#{device_details.inspect}"
                if !device_details.blank?
                 notify_string ="LINKED,"+user.full_name + ","+ params[:question_id]
                 device_details.each do |d|
                      send_device_notification(d[:device_token].to_s, notify_string ,d[:platform].to_s)
                 end
                 # send_device_notification(device_details[:device_token], notify_string ,user_details[0][:platform])
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
        #msg = { :status => 200, :message => "success"}
       #render :json =>msg
        message_options = {
        #optional parameters below.  Read the docs here: http://developer.android.com/guide/google/gcm/gcm.html#send-msg
          :collapse_key => "foobar",
          :data => { :score => "3x1" },
          :delay_while_idle => true,
          :time_to_live => 1,
          :registration_ids => destination
        }
        response = SpeedyGCM::API.send_notification(message_options)
        msg = { :status => 200, :code => response[:code],:data=>response[:data]}
        render :json =>msg 
    end
    
    
    
       
   def post_question_with_image            
        @user = User.find_by_reecher_id(params[:user_id])
        @question = Question.new()
        @question.post = params[:question]
        @question.posted_by_uid = @user.reecher_id
        @question.posted_by = @user.full_name
        @question.ups = 0
        @question.downs = 0 
        @question.Charisma = 5
        @question.category_id = params[:category_id]
        if @user.points > @question.Charisma   
          @question.add_points(@question.Charisma)
          @user.subtract_points(10)
          if !params[:file].blank? 
           @question.avatar = params[:file]  
          end 
           #  data = StringIO.new(Base64.decode64(params[:attached_image]))
           # @question.avatar = data
           #uploaded_file = params[:file]
=begin           
         # @question.avatar_file_name =uploaded_file.original_filename
          
         #@question.avatar_content_type =uploaded_file.content_type
          puts "uploaded_file.==#{uploaded_file.inspect}"
          image_path = (@question.id).to_s + "_question_"+ (uploaded_file.original_filename).to_s
          File.open(Rails.root.join('public', 'uploads', image_path), 'wb') do |file|
          file.write(uploaded_file.read)
        end
              
=end
            
            if params[:audien_details].class == 'String' 
            params[:audien_details] = JSON.parse(params[:audien_details])
            # Setting audiens for displaying posetd user details of a question
            if !params[:audien_details].nil? 
              
              
                  if params[:audien_details].has_key?("emails")             
                  if !params[:audien_details][:emails].empty?
                    audien_reecher_ids = []
                    params[:audien_details][:emails].each do |email|
                      user = User.find_by_email(email)
                      # If audien is a reecher store his reedher_id in question record
                      # Else send an Invitation mail to the audien
                      if user.present?
                        audien_reecher_ids << user.reecher_id
                      else
                      begin
                        UserMailer.send_question_details_to_audien(email, @user).deliver
                      rescue Exception => e
                        logger.error e.backtrace.join("\n")
                      end
                        
                      end 
                    end 
                    @question.audien_user_ids = audien_reecher_ids if audien_reecher_ids.size > 0
                  end 
              
              
              
            end
              # If the audien is not a reecher and have contact number then send an SMS
              if params[:audien_details].has_key?("phone_numbers")     
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
             end
             if params[:audien_details].has_key?("reecher_ids") 
              if !params[:audien_details][:reecher_ids].empty? 
                 params[:audien_details][:reecher_ids].each do |reech_id|
                 user = User.find_by_reecher_id(reech_id)
                 PostQuestionToFriend.create(:user_id =>@user.reecher_id ,:friend_reecher_id =>user.reecher_id)
                  begin
                    UserMailer.send_question_details_to_audien(user.email, user).deliver
                  rescue Exception => e
                    logger.error e.backtrace.join("\n")
                  end
                 
                end 
                
              end
            end 
              
            end  

            end 
             if @question.save
             catgory = Category.find(@question.category_id)
             @question[:category_name] = catgory.title
               msg = {:status => 200, :question => @question, :message => "Question broadcasted for 10 Charisma Creds! Solutions come from your experts - lend a helping hand in the mean time and get rewarded!"} 
             else 
               msg = {:status => 401, :message => @question.errors}
             end
          logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"
          render :json => msg
        else
          msg = {:status => 401, :message => "Sorry, you need at least 10 Charisma Credits to ask a Question! Earn some by providing Solutions!"}                   
          logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{ msg}"
          render :json => msg 
        end

    end
    
    
  
  
     
     
  #  End for class, modules
    end
  end
end
