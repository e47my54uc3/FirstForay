module Api
	module V1
		class UserSessionsController < ApplicationController

		respond_to :json

			def new
				if !current_user.nil?
					respond_to do |format|
						msg = { :status => 401, :message => "Already logged in!"}
						logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
						format.json { render :json => msg }  # note, no :location or :status options
					end
				else
					@user_session = UserSession.new
				end
			end
			
			def create
				if !current_user.nil?
					respond_to do |format|
						msg = { :status => 400, :message => "Already logged in!"}
						logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
						format.json { render :json => msg }  # note, no :location or :status options
					end
				else
					if params[:provider] == "standard"

						@user_session = UserSession.new(params[:user_details])
						if @user_session.save
							respond_to do |format|
								@user_id = User.find_by_email(@user_session.email).reecher_id
								@api_key = ApiKey.create(:user_id => @user_id).access_token
								msg = { :status => 201, :message => "Success!", :email => @user_session.email, :api_key => @api_key, :user_id => @user_id}
								logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
								format.json { render :json => msg }  # note, no :location or :status options
							end
						else
							respond_to do |format|
								msg = { :status => 401, :message => "Please check your Email/Password"}
								logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
								format.json { render :json => msg }  # note, no :location or :status options
							end
						end 
					elsif params[:provider] == "facebook"
						msg = { :status => 200, :message => "Work Under progress"}
						logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
						render :json => msg
					else  
						msg = { :status => 401, :message => "Failure!"}
						logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
						render :json => msg
					end
				end
			end

			def show
				@user=current_user
				respond_to do |format|
					format.json { render :json => @user }  # note, no :location or :status options
				end
			end

			
			def destroy
				api_key = ApiKey.find_by_access_token_and_user_id(params[:api_key], params[:user_id])
				if current_user_session.nil? && !api_key.present? 
					respond_to do |format|
						msg = { :status => 401, :message => "Not logged in!"}
						logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
						format.json { render :json => msg }  # note, no :location or :status options
					end
				elsif current_user_session.nil? && api_key.present? 
					api_key.destroy if !api_key.blank?
					respond_to do |format|
						msg = { :status => 200, :message => "Success!"}
						logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
						format.json { render :json => msg }  # note, no :location or :status options
					end
				else
					current_user_session.destroy
					api_key.destroy 
					respond_to do |format|
						msg = { :status => 200, :message => "Success!"}
						logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
						format.json { render :json => msg }  # note, no :location or :status options
					end
				end
			end

			def check_connection
				msg = { :status => 200, :message => "verified connection"}
				render :json => msg
			end  

		end
	end
end
