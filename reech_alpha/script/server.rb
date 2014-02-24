#!/usr/bin/env ruby

#APP PATH
APP_PATH = ENV['REECH_PATH']
# Location of unicorn rails
DAEMON="`which unicorn_rails`".freeze
# Example : DAEMON_OPTS="-p 5000 -c /home/ubuntu/reech/config/unicorn.rb -D"
DAEMON_OPTS=ENV["REECH_UNICORN_OPTS"].freeze
# Example for PID path PID='/home/ubuntu/reech/shared/pids/unicorn.pid'
PID=ENV["REECH_UNICORN_PID"].freeze
#Example : SBCHAT_DAEMON_OPTS = "-s thin -E production"
SBCHAT_DAEMON_OPTS=ENV["REECH_FAYE_THIN_OPTS"].freeze
#Example for SBCHAT PID Path : SBCHAT_PID =  '/home/ubuntu/reech/shared/pids/faye_thin.pid'
SBCHAT_PID=ENV["REECH_FAYE_THIN_PID"].freeze

UNAME="Unicorn Server for Reech => ".freeze
SBCHAT_UNAME="Thin Server for Reech Chat => ".freeze
RUNTIME_ENV=ENV["REECH_ENVIRONMENT"]

class ServerBoot
	class << self

		def start
			if !pid?
				puts " #{UNAME} Starting"
				system "#{DAEMON} #{DAEMON_OPTS} -E #{RUNTIME_ENV}"
				puts " #{UNAME} Started"
				start_sbchat
			else
				puts " There is instance of #{UNAME} already running"
			end
		end

		def stop
			if pid?
				puts " #{UNAME} Stopping"
				system "kill #{pid}"
				puts " #{UNAME} Stopped"
				stop_sbchat
			else
				puts " There are no instances of #{UNAME} running"
			end
		end

		def restart
			puts " #{UNAME} Re-Starting"
			stop
			sleep 5
			start
		end


		def start_sbchat
			if !sbchat_pid?
				puts " #{SBCHAT_UNAME} Starting"
				system "bundle exec rackup #{APP_PATH}/reech_chat.ru -D -P #{SBCHAT_PID} #{SBCHAT_DAEMON_OPTS}"
				puts " #{SBCHAT_UNAME} Started"
			else
				restart_sbchat
			end
		end

		def stop_sbchat
			if sbchat_pid?
				puts " #{SBCHAT_UNAME} Stopping"
				system "pkill -f #{SBCHAT_PID}"
				puts " #{SBCHAT_UNAME} Stopped"
			else
				puts " There are no instances of #{SBCHAT_UNAME} running"
			end
		end

		def restart_sbchat
			if sbchat_pid?
				puts " #{SBCHAT_UNAME} Re-Starting"
				stop_sbchat
				start_sbchat
			else
				puts " There are no instances of #{SBCHAT_UNAME} running"
			end
		end

		def pid
			File.read "#{PID}"
		end

		def pid?
			File.exists?("#{PID}")
		end

		def sbchat_pid?
			File.exists?("#{SBCHAT_PID}")
		end

	end
end

case ARGV[0]
	when "start"
		ServerBoot.start
	when "reload"
		ServerBoot.reload
	when "restart"
		ServerBoot.restart
	when "stop"
		ServerBoot.stop
	when "graceful_stop"
		ServerBoot.graceful_stop
	else
		STDERR.puts "usage ./script/server [start|stop|restart]"
		exit(1)
end