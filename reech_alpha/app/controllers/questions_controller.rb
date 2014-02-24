class QuestionsController < ApplicationController
  # GET /questions
  # GET /questions.json
  def index
    @questions = Question.find(:all, :order => 'questions.created_at DESC')
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
				format.html { redirect_to root_path }
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
