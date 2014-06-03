module Api
	module V1
		class UserSettingsController < ApiController
			before_filter :restrict_access
			respond_to :json

			def view_settings
				@user = User.find_by_reecher_id(params[:user_id])
				msg = {:status => 200, :settings => @user.user_settings }
				render :json => msg
			end	

			def update_settings
				@user = User.find_by_reecher_id(params[:user_id])
				user_settings = @user.user_settings
				user_settings.location_is_enabled = params[:location]
				user_settings.pushnotif_is_enabled = params[:push_notification]
				user_settings.emailnotif_is_enabled = params[:email]
				user_settings.notify_question_when_answered = params[:question_has_answer]
				user_settings.notify_linked_to_question = params[:linked_question]
				user_settings.notify_solution_got_highfive = params[:high5]
				user_settings.save  
				msg = {:status => 200, :settings => @user.user_settings }
				render :json => msg
			end
				
			def self.check_notify_question_when_answered user_id
			  
			 # UserSettings.find_bu_pushnotif_is_enabled_and_notify_question_when_answered
			  usetting = view_settings user_id 
			  if ((usetting[:pushnotif_is_enabled]== true) && (usetting[:notify_question_when_answered]== true))
			   render true;
			  else
			   render false; 
			  end
			  
			end
				
			def self.notify_linked_to_question  
        
         # UserSettings.find_bu_pushnotif_is_enabled_and_notify_question_when_answered
        usetting = view_settings user_id
        if ((usetting[:pushnotif_is_enabled]== true) && (usetting[:notify_linked_to_question] == true))
         render true;
        else
         render false; 
        end
      
          
      end	
				
			def self.notify_solution_got_highfive user_id
			  
			    # UserSettings.find_bu_pushnotif_is_enabled_and_notify_question_when_answered
        usetting = self.view_settings  
        if ((usetting[:pushnotif_is_enabled]== true) && (usetting[:notify_solution_got_highfive] == true))
         render true;
        else
         render false; 
        end
			  
			end	
				
		end
	end
end			