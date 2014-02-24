class TimelineBeautify
	def self.beauty_time(timestamp)
	    seconds_ago = Time.now.to_i - Time.at(timestamp.to_i).to_i
		minutes_ago = seconds_ago / 60
		hours_ago = minutes_ago / 60
		days_ago = hours_ago / 24
		weeks_ago = days_ago / 7
		months_ago = weeks_ago / 4
		years_ago = months_ago / 12
			if minutes_ago < 1
				return "#{seconds_ago} seconds ago" if seconds_ago!=1
				return "#{seconds_ago} second ago" if seconds_ago==1
			elsif hours_ago < 1
				return "#{minutes_ago} minutes ago" if minutes_ago!=1
				return "#{minutes_ago} minute ago" if minutes_ago==1
			elsif days_ago < 1
				return "#{hours_ago} hours ago" if hours_ago!=1
				return "#{hours_ago} hour ago" if hours_ago==1
			elsif weeks_ago < 1
				return "#{days_ago} days ago" if days_ago!=1
				return "#{days_ago} day ago" if days_ago==1
			elsif months_ago < 1
				return "#{weeks_ago} weeks ago" if weeks_ago!=1
				return "#{weeks_ago} week ago" if weeks_ago==1
			elsif years_ago < 1
				return "#{months_ago} months ago" if months_ago!=1
				return "#{months_ago} month ago" if months_ago==1
			else
				return "#{years_ago} years ago" if years_ago!=1
				return "#{years_ago} year ago" if years_ago==1
			end
	end
end