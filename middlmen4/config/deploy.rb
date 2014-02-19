#Deployment Server is running on the following most important platforms
#rvm 1.22.3 (stable)
#ruby 1.9.3p448
#rails 3.2.13
#capistrano (2.14.1)
#rvm-capistrano (1.2.7)
#Phusion Passenger version 3.0.19
#Apache/2.2.20
#Note : Put EC2_SERVER_URL (your End-point URL or Elastic IP to Amazon EC2 Box) 
#       and GIT_REPO_URL in your ~/.bashrc and source ~/.bashrc before running

set :rvm_ruby_string, '1.9.3'  #global in deployment server
set :rvm_type, :system #system-wide RVM installation in server
require "rvm/capistrano"
set :application, "socialbeam"
set :scm, :git
set :repository,ENV['GIT_REPO_URL']
set :scm_passphrase,""
set :branch, "socialbeam-aws"
set :user, "ubuntu"
set :deploy_to, "/var/www/socialbeam-production"
set :rails_env, "production"


set :domain,ENV['EC2_SERVER_URL']
role :app, domain
role :web, domain
role :db, domain, :primary => true
server ENV['EC2_SERVER_URL'], :app, :roles=>:db,:primary => true

#Cleaning up older releases > 5
set :keep_releases, 5
after "deploy:restart", "deploy:cleanup" 
#Running Migrations after deployment
after 'deploy:update_code', 'deploy:migrate'


#restart  Passenger mod_rails
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
  run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
 end
end
