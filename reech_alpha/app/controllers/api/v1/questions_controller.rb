module Api
  module V1
    class QuestionsController < ApiController
    #http_basic_authenticate_with name: "admin", password "secret"
    require 'thread'
    before_filter :restrict_access , :except =>[:index,:send_apns_notification,:send_gcm_notification]
    before_filter :set_create_params, only: [:create]
    after_filter :send_notifications, only: [:create]
    #doorkeeper_for :all
    respond_to :json

    def index
      #user = User.find_by_reecher_id(params[:user_id])
      @questions = Question.get_questions(params[:type], current_user)

      render "index.json.jbuilder"
    end

    def show
        @question = Question.find(params[:id])
        @solutions = Solution.filter(@question, current_user)
        @allsolutions = @question.posted_solutions
        respond_with @question, @solutions, @allsolutions
    end

    def mark_question_stared
      @question = Question.find_by_question_id(params[:question_id])      
      if params[:stared] == "true"
        @voting = Voting.where(user_id: current_user.id, question_id: @question.id).first
        if @voting.blank?
        @voting = Voting.new do |v|
                  v.user_id = current_user.id
                  v.question_id = @question.id
                end
        @voting.save ? msg = {:status => 200, :message => "Successfully Stared",:is_login_user_starred_qst=>true} : msg = {:status => 401, :message => "Failed!",:is_login_user_starred_qst=>false}
       else
        msg = {:status => 200, :message => "Already Stared",:is_login_user_starred_qst=>true}
       end  
      elsif params[:stared] == "false"
        @voting = Voting.where(user_id: current_user.id, question_id: @question.id).first
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
      @question = Question.find_by_question_id(params[:question_id]) 
      puts "link_questions_to_expert==#{params.inspect}"
      if !@question.blank?
      # Outer if condition    
          if !params[:audien_details].nil?            
             Thread.new{link_questions_to_expert_for_users params[:audien_details] , current_user,@question.question_id}
             Thread.new{send_posted_question_notification_to_chosen_emails params[:audien_details], current_user, @question,PUSH_TITLE_LINKED,"LINKED","LINKED"}
             Thread.new{send_posted_question_notification_to_chosen_phones params[:audien_details], current_user, @question,PUSH_TITLE_LINKED,"LINKED","LINKED"}
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
        post_quest_to_frnd=[]
        if @user.points > @question.Charisma   
          @question.add_points(@question.Charisma)
          @user.subtract_points(10)
            if !params[:file].blank? 
              @question.avatar = params[:file]  
             end 
             params[:audien_details] = JSON.parse(params[:audien_details]) 
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
    
    
  def send_posted_question_notification_to_reech_users audien_details ,user,question,push_title_msg,push_contant_str,linked_quest_type
     puts " I am in send_posted_question_notification_to_reech_users"
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
                           check_email_setting_for_ask_for_help = check_email_audience_if_ask_for_help user_details_with_reech_id.reecher_id if !user_details_with_reech_id.blank?
                          
                           puts "user_details_with_reech_id========#{user_details_with_reech_id.email}"
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
                             puts "user_details_with_reech_id========#{user_details_with_reech_id.email}"
                              if user_details_with_reech_id.email !=nil
                                puts "user_details_with_reech_id========#{user_details_with_reech_id.email}"
                                UserMailer.send_question_details_to_audien(user_details_with_reech_id.email, user_details_with_reech_id.first_name,question, user).deliver  if check_email_setting_for_ask_for_help
                              
                              end
                            rescue Exception => e
                             logger.error e.backtrace.join("\n")
                            end
                            
                       end # end of do
                      
                    end
              end
     end
   end
  
 
  #  End for class, modules
    private

    def set_create_params
      old_params = params
      
      params[:question] = {
        post: old_params[:question], 
        posted_by_uid: current_user.reecher_id, 
        posted_by: current_user.full_name,
        ups: 0,
        downs: 0,
        Charisma: 5,
        category_id: old_params[:category_id],
      }

      if !old_params[:attached_image].blank? 
        data = StringIO.new(Base64.decode64(old_params[:attached_image]))
        params[:question][:avatar] = data
      end
    
      if old_params[:audien_details].blank? || (old_params[:audien_details][:reecher_ids].blank? && old_params[:audien_details][:emails].blank? && old_params[:audien_details][:phone_numbers].blank?) 
        params[:question][:is_public] = true
      end
      params[:audien_details] = old_params[:audien_details]
    end

    def send_notifications
      if !params[:audien_details].nil?
        Thread.new{send_posted_question_notification_to_reech_users params[:audien_details], current_user, entry,PUSH_TITLE_ASKHELP,"ASKHELP","ASK"}
        Thread.new{send_posted_question_notification_to_chosen_emails params[:audien_details], current_user, entry,PUSH_TITLE_ASKHELP,"ASKHELP","ASK"}
        Thread.new{send_posted_question_notification_to_chosen_phones params[:audien_details], current_user, entry,PUSH_TITLE_ASKHELP,"ASKHELP","ASK"}
      end
      post_quest_to_frnd = []
      if !post_quest_to_frnd.blank? 
        post_quest_to_frnd.each do|pqf|                 
          @pqtf= PostQuestionToFriend.find(pqf)                 
          @pqtf.update_attributes(:question_id=>entry.question_id) 
        end
      end
    end

    def link_questions_to_expert_for_users audien_details ,user,question_id
      reecher_ids = params[:audien_details][:reecher_ids]
      if !reecher_ids.blank?
        User.where(reecher_id: reecher_ids).each do |audien_user|
          if !audien_user.linked_with_question?(question_id, user)
            audien_user.linked_questions.create(question_id: question_id, linked_by_uid: user.reecher_id, email_id: audien_user.email, phone_no: audien_user.phone_number,:linked_type=>'LINKED')
            if audien_user.notify_when_question_linked?
              @question = Question.find_by_question_id(question_id)
              UserMailer.email_linked_to_question(audien_user.email, user, @question).deliver  unless audien_user.email.blank?
              notify_string ="LINKED,"+ "<" +user.full_name + ">" + ","+ question_id.to_s + "," +Time.now().to_s
              audien_user.devices.each do |d|
                send_device_notification(d[:device_token].to_s, notify_string ,d[:platform].to_s,user.full_name+PUSH_TITLE_LINKED)
              end
            end
          end
        end
      end
    end
    
    end
  end
end
