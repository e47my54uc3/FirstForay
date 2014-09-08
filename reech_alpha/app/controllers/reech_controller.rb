class ReechController < ApplicationController
  respond_to :html, :xml, :js, :json
  before_filter :update_questionstreams, :only => [:home, :refreshquestions]
  before_filter :update_newsfeedsstream, :only => [:home]
  
  def home
    if current_user
      @questions = Question.get_questions(:feed,current_user)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @questions}
    end
  end

  def reechtest
    respond_to do |format|
      render :text => "Successful login"
    end
  end

  def loadmorequestions
    @questions_streams = Question.paginate(:page => params[:page], :per_page =>5).order('created_at DESC')
    if @questions_streams.total_pages >= @questions_streams.current_page
    render :partial => 'questions/questions', :locals=>{:questions_streams=>@questions_streams}
    else
    render :nothing=>true
    end
  end

   #  def votedup
   #   @question = Question.find(params[:id])
   #   @question.ups=@question.ups+1
   #   @question.save
   #   render :text => "<i class='icon-thumbs-up'></i>"+@question.ups.to_s+" likes"
   # end

   # def voteddown
   #   @question = Question.find(params[:id])
   #   @question.downs=@question.downs+1
   #   @question.save
   #   render :text => "<i class='icon-thumbs-down'></i>"+@question.downs.to_s+" dislikes"
   # end

   def refreshquestions
    render :partial => 'questions/questions.html.erb', :locals => { :questions_streams => @questions_streams }
  end

  protected
  def update_questionstreams
    @questions_streams = Question.paginate(:page => params[:page], :per_page =>5).order('created_at DESC')
  end 
  def update_newsfeedsstream
    @newsfeeds_streams = Newsfeed.paginate :per_page => 20, :order => "created_at DESC", :page => params[:page]
  end
end
