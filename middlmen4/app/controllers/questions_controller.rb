class QuestionsController < ApplicationController
  # GET /Questions
  # GET /Questions.json
  def index
    @Questions = Question.find(:all, :order => 'Questions.created_at DESC')
      respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @Questions }
    end
  end

  # GET /Questions/1
  # GET /Questions/1.json
  def show
    @Question = Question.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @Question }
    end
  end


  # GET /Questions/1/edit
  def edit
    @Question = Question.find(params[:id])
  end

  # POST /Questions
  # POST /Questions.json
  def create
    @Question = Question.new(params[:Question])
    @Question.posted_by_uid=current_user.beamer_id
    @Question.posted_by=current_user.full_name
    @Question.ups=0
    @Question.downs=0
	 @Question.Charisma=5
		if current_user.points>@Question.Charisma	 
			@Question.add_points(@Question.Charisma)
			current_user.subtract_points(10)
			respond_to do |format|
     			 if @Question.save!
					flash[:notice] = "Question broadcasted for 10 Charisma Creds! Solutions come from your experts - lend a helping hand in the mean time and get rewarded!"        			
					format.html { redirect_to root_path }
        			format.json { render :json => @Question, :status => :created, :location => @Question }
      		else
        			format.html { redirect_to root_path }
        			format.json { render :json => @Question.errors, :status => :unprocessable_entity }
      		end
    		end
		else
			respond_to do |format|			
				flash[:notice] = "Sorry, you need at least 10 Charisma Creds to ask a Question! Earn some by providing Solutions!"				
				format.html { redirect_to root_path }
			end
		end
  end

  # PUT /Questions/1
  # PUT /Questions/1.json
  def update
    @Question = Question.find(params[:id])

    respond_to do |format|
      if @Question.update_attributes(params[:Question])
        format.html { redirect_to @Question, :notice => 'Question was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @Question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /Questions/1
  # DELETE /Questions/1.json
  def destroy
    @Question = Question.find(params[:id])
    @Question.destroy

    respond_to do |format|
      format.html { redirect_to Questions_url }
      format.json { head :no_content }
    end
  end
end
