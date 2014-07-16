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
			
			# This method is used for create a session for standard user
			def create
				if params[:provider] == "standard"
					@user_session = UserSession.new(params[:user_details])
			
					if @user_session.save
						respond_to do |format|
							@user_id = User.find_by_phone_number(@user_session.phone_number)							
							@api_key = ApiKey.create(:user_id => @user_id.reecher_id).access_token
							#create a device token entry in device table for push notifications
							if !params[:device_token].blank? && !params[:platform].blank?
							  existing_device = Device.where(:device_token => params[:device_token], :platform => params[:platform], :reecher_id => @user_id.reecher_id)
							  if !existing_device.present?
							    device = Device.new()
							    device.device_token = params[:device_token]
							    device.platform = params[:platform]
							    device.reecher_id = @user_id.reecher_id
							    device.save
							  end  
							end  
							msg = { :status => 201, :message => "Success!", :api_key => @api_key, :user_id => @user_id.reecher_id,:email=>@user_id.email,:phone_number=>@user_id.phone_number.to_i}
							logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
							format.json { render :json => msg }  # note, no :location or :status options
						end
					else
						respond_to do |format|
							msg = { :status => 401, :message => @user_session.errors}
							logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
							format.json { render :json => msg }  # note, no :location or :status options
						end
					end
				else  
					msg = { :status => 401, :message => "Failure!"}
					logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
					render :json => msg
				end
			end
			# This method is no more used in application
			def show
				@user=current_user
				respond_to do |format|
					format.json { render :json => @user }  # note, no :location or :status options
				end
			end


			# This method is used for destroy session.
			def destroy
				api_key = ApiKey.find_by_access_token_and_user_id(params[:api_key], params[:user_id])
				device = Device.find_by_reecher_id(params[:user_id])
				if current_user_session.nil? && !api_key.present? 
					respond_to do |format|
						msg = { :status => 401, :message => "Not logged in!"}
						logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
						format.json { render :json => msg }  # note, no :location or :status options
					end
				elsif current_user_session.nil? && api_key.present? 
					api_key.destroy if !api_key.blank?
					device.destroy if !device.blank?
					respond_to do |format|
						msg = { :status => 200, :message => "Success!"}
						logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
						format.json { render :json => msg }  # note, no :location or :status options
					end
				else
					current_user_session.destroy
					api_key.destroy 
					device.destroy if !device.blank?
					respond_to do |format|
						msg = { :status => 200, :message => "Success!"}
						logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
						format.json { render :json => msg }  # note, no :location or :status options
					end
				end
			end

			# This method is used to check connection.
			def check_connection
				msg = { :status => 200, :message => "verified connection"}
				render :json => msg
			end  

		end
	end
end
