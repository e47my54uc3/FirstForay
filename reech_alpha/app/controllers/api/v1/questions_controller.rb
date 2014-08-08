module Api
  module V1
    class QuestionsController < ApiController
    #http_basic_authenticate_with name: "admin", password "secret"
    require 'thread'
    before_filter :restrict_access , :except =>[:index,:send_apns_notification,:send_gcm_notification]
    #doorkeeper_for :all
    respond_to :json

    def index
      @Questions = [] 
      questions_hash = []
      user = User.find_by_reecher_id(params[:user_id])
      if params[:type] == "feed"
         friends_reecher_ids = []
        friends_reecher_ids << user.reecher_id
        user_friends = Friendship.where(:reecher_id => user.reecher_id, :status => 'accepted')
        if user_friends.size > 0
          user_friends.each do |uf|
            friends_reecher_ids << uf.friend_reecher_id
          end
        end
        @Questions = []
        @Questions_obj = Question.where("posted_by_uid  IN (?) AND created_at>=?" , friends_reecher_ids.to_a ,user.created_at).order("created_at DESC")
        @Questions = Question.filterforuser user.reecher_id , @Questions_obj 
       
      elsif params[:type] == "stared"
        question_ids = Voting.select("question_id").where("user_id = ?", user.id) unless user.blank?  
        question_ids = question_ids.map{|q| q.question_id}
        @Questions_obj = Question.where("id in (?)", question_ids).order("created_at DESC")  unless user.blank? 
        @Questions = Question.filterforuser user.reecher_id , @Questions_obj 
        
      elsif params[:type] == "self"
        @Questions = user.questions.order("created_at DESC")
        my_purchases_solid = PurchasedSolution.select(:solution_id).where("user_id = ?", user.id) 
        quest_hash =[]
        my_purchases_solid.each do |sid|
        qust_purc_sol=Question.joins(:solutions)
                   .select("questions.*,solutions.id as sol_id,solutions.question_id as sol_question_id")
                   .where("solutions.id = ?", sid.solution_id)
        quest_hash.push(qust_purc_sol[0][:id]) unless qust_purc_sol.blank?
        end
        my_quest= @Questions.map{|q| q.id}
        merge_question = quest_hash + my_quest
        my_all_question = merge_question.sort
        @Questions_obj = Question.where("id in (?)", my_all_question).order("created_at DESC")        
        @Questions = Question.filterforuser user.reecher_id , @Questions_obj 
          
      end 
      
     
      #referred_friend_ids = PostQuestionToFriend::get_referred_friend_ids current_user.reecher_id
      
      
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
          if !q.avatar_file_name.blank?
             avatar_geo=((q.avatar_geometry).to_s).split('x') 	
	           q_hash[:image_width]=avatar_geo[0]	
	          q_hash[:image_height] = avatar_geo[1] 	
	       end

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
        post_quest_to_frnd=[]
        if @user.points > @question.Charisma   
          @question.add_points(@question.Charisma)
          @user.subtract_points(10)
            if !params[:attached_image].blank? 
              data = StringIO.new(Base64.decode64(params[:attached_image]))
              @question.avatar = data
              
            end
            
             if params[:audien_details].blank? || (params[:audien_details][:reecher_ids].blank? && params[:audien_details][:emails].blank? && params[:audien_details][:phone_numbers].blank?) 
              @question.is_public = true
             end 
            
             if @question.save
             catgory = Category.find(@question.category_id)             
             if !params[:audien_details].nil?
             Thread.new{send_posted_question_notification_to_reech_users params[:audien_details], @user, @question,PUSH_TITLE_ASKHELP,"ASKHELP","ASK"}
             Thread.new{send_posted_question_notification_to_chosen_emails params[:audien_details], @user, @question,PUSH_TITLE_ASKHELP,"ASKHELP","ASK"}
             Thread.new{send_posted_question_notification_to_chosen_phones params[:audien_details], @user, @question,PUSH_TITLE_ASKHELP,"ASKHELP","ASK"}
             end
             if !post_quest_to_frnd.blank? 
             post_quest_to_frnd.each do|pqf|                 
              @pqtf= PostQuestionToFriend.find(pqf)                 
              @pqtf.update_attributes(:question_id=>@question.question_id) 
              end
             end
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
        @voting.save ? msg = {:status => 200, :message => "Successfully Stared",:is_login_user_starred_qst=>true} : msg = {:status => 401, :message => "Failed!",:is_login_user_starred_qst=>false}
       else
        msg = {:status => 200, :message => "Already Stared",:is_login_user_starred_qst=>true}
       end  
      elsif params[:stared] == "false"
        @voting = Voting.where(user_id: @user.id, question_id: @question.id).first
        if @voting.present?
          @voting.destroy
          @voting.destroyed? ? msg = {:status => 200, :message => "Successfully UnStared",:is_login_user_starred_qst=>false} : msg = {:status => 401, :message => "Failed!",:is_login_user_starred_qst=>false}
        else
          msg = {:status => 200, :message => "Already UnStared",:is_login_user_starred_qst=>false}
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
      linked_questions = LinkedQuestion.where("user_id = ? and linked_type =? ",user.reecher_id, "LINKED").order("id DESC")
      if !linked_questions.empty? &&  linked_questions.size >0
          linked_questions_ary = []
           purchasedSolutionId =PurchasedSolution.pluck(:solution_id) # get all grab solution id
            linked_questions.each do |lq|
             question = Question.find_by_question_id(lq[:question_id]) 
             solutions = Solution.find_all_by_question_id(lq[:question_id])
             solutions = solutions.collect!{|i| (i.id).to_s}   
             @get_linked_by = LinkedQuestion.where("user_id = ? and question_id = ? ", user.reecher_id , lq[:question_id])
              #question_owner = User.find_by_reecher_id(question.posted_by_uid)
              if !@get_linked_by.blank?
                question_owner = User.find_by_reecher_id(@get_linked_by[0]['linked_by_uid'])
              else
                msg = { :status => 401, :message => "Failure!"}
                render :json => msg
              end
              question_owner_profile = question_owner.user_profile
              
              q_hash = question.attributes if !question.blank?
              has_solution= purchasedSolutionId & solutions              
              has_solution.size > 0 ? q_hash[:has_solution] = true : q_hash[:has_solution] = false
              question.is_stared? ? q_hash[:stared] = true : q_hash[:stared] =false
              question.avatar_file_name != nil ? q_hash[:image_url] =   question.avatar_url : q_hash[:image_url] = nil
              q_hash[:owner_location] = question_owner_profile.location
              q_hash[:question_linked_by_user] = question_owner.full_name
              question_owner_profile.picture_file_name != nil ? q_hash[:owner_image] =   question_owner_profile.picture_url : q_hash[:owner_image] = nil
              
             if !question.avatar_file_name.blank?
             avatar_geo=((question.avatar_geometry).to_s).split('x') 	
	           q_hash[:image_width]=avatar_geo[0]	
	           q_hash[:image_height] = avatar_geo[1] 
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
      @user = User.find_by_reecher_id(params[:user_id])
      @question = Question.find_by_question_id(params[:question_id]) 
      if ((!@user.blank?) && (!@question.blank?))
      # Outer if condition    
          if !params[:audien_details].nil? 
             Thread.new{link_questions_to_expert_for_users params[:audien_details] ,@user,@question.question_id}
             Thread.new{send_posted_question_notification_to_chosen_emails params[:audien_details], @user, @question,PUSH_TITLE_LINKED,"LINKED","LINKED"}
             Thread.new{send_posted_question_notification_to_chosen_phones params[:audien_details], @user, @question,PUSH_TITLE_LINKED,"LINKED","LINKED"}
=begin
             any_linked = false
             
             if !params[:audien_details][:reecher_ids].blank?
                 params[:audien_details][:reecher_ids].each do |reech_id|
                  user_details =User.find_by_reecher_id(reech_id)
                  check_linked_question  = is_question_linked_to_user question_id ,user_details.reecher_id,user.reecher_id 
                  if check_linked_question
                     any_linked = true
                     break
                  end
                end
            end  
=end           
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
           post_quest_to_frnd=[]
           params[:audien_details] = JSON.parse(params[:audien_details]) 
            if params[:audien_details].blank? || (params[:audien_details][:reecher_ids].blank? && params[:audien_details][:emails].blank? && params[:audien_details][:phone_numbers].blank?)
              @question.is_public = true
            end 
             if @question.save
             catgory = Category.find(@question.category_id)
             @question[:category_name] = catgory.title
             if params[:audien_details].class.to_s == 'String'            
                        
            # Setting audiens for displaying posetd user details of a question
             if !params[:audien_details].blank?  
             Thread.new{send_posted_question_notification_to_reech_users params[:audien_details], @user, @question,PUSH_TITLE_ASKHELP,"ASKHELP","ASK"}
             Thread.new{send_posted_question_notification_to_chosen_emails params[:audien_details], @user, @question,PUSH_TITLE_ASKHELP,"ASKHELP","ASK"}
             Thread.new{send_posted_question_notification_to_chosen_phones params[:audien_details], @user, @question,PUSH_TITLE_ASKHELP,"ASKHELP","ASK"}
             end  # end of nil checking
             
            if !post_quest_to_frnd.blank?  
               post_quest_to_frnd.each do|pqf|
               @pqtf= PostQuestionToFriend.find(pqf)                 
               @pqtf.update_attributes(:question_id=>@question.question_id) 
               end
             end 
              
            end # end of string class checking 
                           
               msg = {:status => 200, :question => @question, :message => "Question broadcasted for 10 Charisma Creds! Solutions come from your experts - lend a helping hand in the mean time and get rewarded!"} 
             else 
               msg = {:status => 401, :message => @question.errors}
             end
          render :json => msg
        else
          msg = {:status => 401, :message => "Sorry, you need at least 10 Charisma Credits to ask a Question! Earn some by providing Solutions!"}                   
          render :json => msg 
        end

    end
    
    
  def send_posted_question_notification_to_reech_users audien_details ,user,question,push_title_msg,push_contant_str,linked_quest_type
     
     if !audien_details.blank?
     if audien_details.has_key?("reecher_ids") 
                 post_quest_to_frnd =[]
                    if !audien_details[:reecher_ids].empty? 
                      post_quest_to_frnd =[]
                       audien_details[:reecher_ids].each do |reech_id|
                           user_details_with_reech_id = User.find_by_reecher_id(reech_id)   
                           pqtf=PostQuestionToFriend.create(:user_id =>user.reecher_id ,:friend_reecher_id =>user_details_with_reech_id.reecher_id, :question_id=>question.question_id)
                           post_quest_to_frnd << pqtf.id
                           check_setting= notify_audience_if_ask_for_help(user_details_with_reech_id.reecher_id) if !user_details_with_reech_id.blank?
                             if check_setting
                                 if !user.blank?
                                     device_details = Device.where(:reecher_id=>user_details_with_reech_id.reecher_id)
                                     if !device_details.blank?
                                     notify_string = push_contant_str + "," + "<"+user.full_name + ">" + "," + question.question_id.to_s + "," + Time.now().to_s
                                       device_details.each do |d|
                                            send_device_notification(d[:device_token].to_s, notify_string ,d[:platform].to_s,user.full_name+push_title_msg)
                                       end
            
                                     end
                                 end  
                             end
                            # Send email notofication to all reecher users
                            begin
                              if user_details_with_reech_id.email !=nil
                              UserMailer.send_question_details_to_audien(user_details_with_reech_id.email, user).deliver
                              end
                            rescue Exception => e
                              logger.error e.backtrace.join("\n")
                            end
                            
                       end # end of do
                      
                    end
              end
     end
   end
  
 
  def link_questions_to_expert_for_users audien_details ,user,question_id
    
    if !params[:audien_details][:reecher_ids].blank?
              all_sent =true
              params[:audien_details][:reecher_ids].each do |reech_id|
              user_details =User.find_by_reecher_id(reech_id)
              check_linked_question  = is_question_linked_to_user question_id ,user_details.reecher_id,user.reecher_id 
              if !check_linked_question          
              LinkedQuestion.create(:user_id =>user_details.reecher_id,:question_id=>question_id,:linked_by_uid=>user.reecher_id,:email_id=>user_details.email,:phone_no =>user_details.phone_number,:linked_type=>'LINKED')
             
              end
              check_setting= notify_linked_to_question(reech_id)
              if check_setting && !check_linked_question
                 if !user_details.blank?
                   device_details = Device.where(:reecher_id=>user_details.reecher_id)
                    if !device_details.blank?
                     notify_string ="LINKED,"+ "<" +user.full_name + ">" + ","+ question_id.to_s + "," +Time.now().to_s
                     device_details.each do |d|
                          send_device_notification(d[:device_token].to_s, notify_string ,d[:platform].to_s,user.full_name+PUSH_TITLE_LINKED)
                       
                     end
                     
                   end
                 end
               end     
              end
            end
  end
  
     
     
  #  End for class, modules
    end
  end
end
