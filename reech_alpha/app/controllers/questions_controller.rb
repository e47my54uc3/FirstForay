class QuestionsController < ApplicationController
  # GET /questions
  # GET /questions.json
  def index
      # @Questions = Question.filterforuser(current_user.reecher_id)
      # respond_to do |format|
      #   format.html # index.html.erb
      #   format.json { render :json => ["Questions:", @Questions] }
      # end
      @questions = [] 
      questions_hash = []
      #user = User.find_by_reecher_id(params[:user_id])
      @questions = Question.get_questions(params[:type], current_user)
      
      #referred_friend_ids = PostQuestionToFriend::get_referred_friend_ids current_user.reecher_id
      
      
      if @questions.size > 0
        purchasedSolutionId =PurchasedSolution.pluck(:solution_id)        
        @questions.each do |q|
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
            puts "QUESTION 1213===#{((q.avatar_geometry).to_s)}"
            
            avatar_geo=((q.avatar_geometry).to_s).split('x')  
            puts "QUESTION ===#{avatar_geo}"
             q_hash[:image_width]=avatar_geo[0] 
            q_hash[:image_height] = avatar_geo[1]   
         end

          q_hash[:owner_location] = question_owner_profile.location
          question_owner_profile.picture_file_name != nil ? q_hash[:owner_image] =   question_owner_profile.thumb_picture_url : q_hash[:owner_image] = nil
          questions_hash << q_hash
          
        end 
      end
        logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{@questions.size}"
        msg = {:status => 200, :questions => questions_hash }
        respond_to do |format|
          format.html # index.html.erb
          format.json { render :json => ["Questions:", @questions] }
        end
  end

  # GET /questions/1
  # GET /questions/1.json
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
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => ["Question:",@question, "Solutions:",@solutions] }

    end
  end


  # GET /questions/1/edit
  def edit
    @question = Question.find(params[:id])
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(params[:question])
    @question.posted_by_uid=current_user.reecher_id
    @question.posted_by=current_user.full_name
    @question.ups=0
    @question.downs=0
	 @question.Charisma=5
		if current_user.points>@question.Charisma	 
			@question.add_points(@question.Charisma)
			current_user.subtract_points(10)
			respond_to do |format|
     			 if @question.save!
					flash[:notice] = "Question broadcasted for 10 Charisma Creds! Solutions come from your experts - lend a helping hand in the mean time and get rewarded!"        			
					format.html { redirect_to root_path }
        			format.json { render :json => @question, :status => :created, :location => @question }
      		else
        			format.html { redirect_to root_path }
        			format.json { render :json => @question.errors, :status => :unprocessable_entity }
      		end
    		end
		else
			respond_to do |format|			
				flash[:notice] = "Sorry, you need at least 10 Charisma Creds to ask a Question! Earn some by providing Solutions!"				
				format.html { red           qust_details[:question_referee] = question_asker_name   
irect_to root_path }
			end
		end
  end

  # PUT /questions/1
  # PUT /questions/1.json
  def update
    @question = Question.find(params[:id])

    respond_to do |format|
      if @question.update_attributes(params[:question])
        format.html { redirect_to @question, :notice => 'Question was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question = Question.find(params[:id])
    @question.destroy

    respond_to do |format|
      format.html { redirect_to questions_url }
      format.json { head :no_content }
    end
  end
end
