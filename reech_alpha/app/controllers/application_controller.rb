class ApplicationController < ActionController::Base
  #protect_from_forgery
  include ApplicationHelper
  include NewsfeedsStreamsData
  helper :all
  #protect_from_forgery
  helper_method :current_user_session, :current_user, :require_user, :fb_user, :recipients
  before_filter :add_common_headers #Filter for add response headers for all JSON API calls

  
  private
  def recipients
    curr_u = current_user
    User.all.reject { |u| u.reecher_id == curr_u.reecher_id }.compact
  end
  
  def set_flash_message(key, kind, options = {})
    message = find_message(kind, options)
    flash[key] = message if message.present?
  end

  def find_message(kind, options = {})
    I18n.t("#{controller_name}.#{kind}", options)
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def require_user
    unless current_user
      flash[:notice] = "You must be logged in to access this page"
      redirect_to signin_path
      return false
    end
  end

  def facebook_user
    (session[:fb_access_token] && session[:fb_user_uid]) ? FBGraph::Client.new(:client_id => GRAPH_APP_ID, :secret_id => GRAPH_SECRET, :token => session[:fb_access_token]).selection.me.info! : nil
  end

  def fb_user
client = FBGraph::Client.new(:client_id => GRAPH_APP_ID, :secret_id => GRAPH_SECRET, :token => token) 
  return @fbuser  
  @fbuser = client.selection.me.info!
  end

  def get_user
    @user ||= User.find_by_reecher_id(params[:reecher_id])
    render(:template => "errors/error_404", :status => 404) if @user.blank?
  end

  #Adding Response headers for a response of JSON API Request
  def add_common_headers
    if request.format == "json"
      response['Access-Control-Allow-Origin'] = '*'
      response['Access-Control-Allow-Methods'] = 'DELETE, HEAD, GET, OPTIONS, POST, PUT' 
    end
  end 
  
end
