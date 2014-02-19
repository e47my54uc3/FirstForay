module Scrubber
	#Generate Random Number of Size 9
	def random_number(size=11)
		Array.new(size){rand(10)}.join.to_i
	end
    #Generate Scribble_ID
    def gen_scribble_id
        begin
            random_id=random_number(11)
            scribble_id=("Scribble-" + "#{random_id}")
        end while Scribble.exists?(:scribble_id =>scribble_id)
        return scribble_id
    end 

    #Generate Beamer_ID
    def gen_beamer_id
    	begin
    		random_id=random_number(11)
    		beamer_id=("Beamer-" + "#{random_id}")
    	end while User.exists?(:beamer_id =>beamer_id)
    	return beamer_id
    end
    #Generate Profile_ID
    def gen_profile_id
        begin
          profile_id=SecureRandom.base64(8)
        end while User.exists?(:profile_id =>profile_id)
        return profile_id
    end  
end