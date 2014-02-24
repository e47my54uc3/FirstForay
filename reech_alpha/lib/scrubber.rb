module Scrubber
	#Generate Random Number of Size 9
	def random_number(size=11)
		Array.new(size){rand(10)}.join.to_i
	end
    #Generate question_ID
    def gen_question_id
        begin
            random_id=random_number(11)
            question_id=("question-" + "#{random_id}")
        end while Question.exists?(:question_id =>question_id)
        return question_id
    end 

    #Generate Reecher_ID
    def gen_reecher_id
    	begin
    		random_id=random_number(11)
    		reecher_id=("Reecher-" + "#{random_id}")
    	end while User.exists?(:reecher_id =>reecher_id)
    	return reecher_id
    end
    #Generate Profile_ID
    def gen_profile_id
        begin
          profile_id=SecureRandom.base64(8)
        end while User.exists?(:profile_id =>profile_id)
        return profile_id
    end  
end