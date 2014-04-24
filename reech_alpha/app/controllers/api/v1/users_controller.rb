module Api
	module V1
		class UsersController < ApplicationController
		respond_to :json
			#http_basic_authenticate_with name: "admin", password: "secret"
			def new
				@user = User.new
				respond_with @user
			end

			def create
				if !params.blank?
					if params[:provider] == "standard"
						if User.find_by_email(params[:user_details][:email]).nil?
								@user = User.new(params[:user_details])
								@user.password_confirmation = params[:user_details][:password]
								if @user.save
									if !params[:profile_image].blank? 
										data = StringIO.new(Base64.decode64(params[:profile_image]))
										@user.user_profile.picture = data
										@user.save
									end
									@user.reset_single_access_token
									@user.add_points(500)
									@api_key = ApiKey.create(:user_id => @user.reecher_id).access_token
									msg = {:status => 201, :api_key=>@api_key, :email=>@user.email, :user_id=>@user.reecher_id}
									logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
									render :json => msg  # note, no :location or :status options
								else
									msg = { :status => 401, :message => @user.errors.full_messages}
									logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
									render :json => msg  # note, no :location or :status option
								end
						else
							 msg = { :status => 401, :message => "Email Already exists"}
							 logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
							 render :json => msg
						end   
					elsif params[:provider] == "facebook"
						fb_user = User.find_by_fb_uid(params[:user_details][:uid])
						@graph = Koala::Facebook::API.new(params[:user_details][:access_token])
						@profile = @graph.get_object("me")
						@fb_friends = @graph.get_connections("me", "friends")
						
						if fb_user.nil?              
							@user = User.new()
							@user.first_name = @profile["first_name"]
							@user.last_name = @profile["last_name"]
							@user.email = @profile["email"]
							@user.fb_token = params[:user_details][:access_token]
							@user.fb_uid = params[:user_details][:uid]
							if @user.save(:validate => false)

								make_friendship(@fb_friends,@user) if @fb_friends.size > 0

								create_session_for_fb_user(@user)
							
								Authorization.create(:user_id => @user.id, :uid => params[:user_details][:uid], :provider => params[:provider])
								@user.add_points(500)
								@api_key = ApiKey.create(:user_id => @user.reecher_id).access_token
								msg = {:status => 201, :api_key=>@api_key, :user_id=>@user.reecher_id}
								logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
								render :json => msg
							end 
						else
							make_friendship(@fb_friends,fb_user) if @fb_friends.size > 0
							create_session_for_fb_user(fb_user)
							@api_key = ApiKey.create(:user_id => fb_user.reecher_id).access_token
							msg = {:status => 201, :api_key=>@api_key, :user_id=>fb_user.reecher_id}
							logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
							render :json => msg
						end 
					end  
				else
					msg = { :status => 401, :message => "Failure!"}
					logger.debug "******Response To #{request.remote_ip} at #{Time.now} => #{msg}"
					render :json => msg
				end      

			end

			
			def show
				@user=current_user
				respond_to do |format|
					format.json { render :json => @user }  # note, no :location or :status options
				end
			end

			def create_session_for_fb_user(user)
				user.reset_persistence_token!
				UserSession.create(user, true)
			end  

			def make_friendship(fb_friends, fb_user)
				fb_friends_list_uids = []
				fb_friends.select {|fu| fb_friends_list_uids << fu["id"] }
				fb_friends_list_uids.each do |f|
					fb_user_existed = User.find_by_fb_uid(f)
					if !fb_user_existed.blank?
						if Friendship.request(fb_user_existed, fb_user)
							Friendship.accept(fb_user_existed, fb_user)
						end  
					end 
				end  
			end  

		end
	end
end

