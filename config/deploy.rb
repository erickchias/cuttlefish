#require 'new_relic/recipes'
require "rvm/capistrano"
require 'bundler/capistrano'
# This links .env to shared
require "dotenv/deployment/capistrano"

set :application, "cuttlefish"
set :repository,  "https://github.com/erickchias/cuttlefish.git"
set :rvm_ruby_string, :local
set :rvm_type, :system
# The default for rvm_path is /usr/local/rvm
set :rvm_path, "/usr/local/lib/rvm"
set :rvm_bin_path, "/usr/local/lib/rvm/bin"
set :rvm_install_with_sudo, true

#server "kedumba.openaustraliafoundation.org.au", :app, :web, :db, primary: true
#server "localhost:2222", :app, :web, :db, primary: true
#server "li743-35.members.linode.com", :app, :web, :db, primary: true
server "vagrant", :app, :web, :db, primary: true
#server "vagrant@localhost:2222", roles: %w[web app db], primary: true

set :use_sudo, false
set :deploy_via, :remote_cache

set :user, "vagrant"
#set :stage, :staging
#set :ssh_options, {
# keys: %w(~/.vagrant.d/insecure_private_key),
# forward_agent: true
#}
#set :deploy_to, "/srv/www/cuttlefish.openaustraliafoundation.org.au"
set :deploy_to, "/srv/www"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

#before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset, or:
before "deploy:restart", "foreman:restart"
before "foreman:restart", "foreman:export"
#after "deploy:restart", "newrelic:notice_deployment"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, roles: :app, except: { no_release: true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "After a code update, we link additional config and data directories"
  before "deploy:assets:precompile" do
    links = {
      "#{release_path}/config/database.yml"                => "#{shared_path}/database.yml",
      "#{release_path}/db/emails"                          => "#{shared_path}/emails",
      "#{release_path}/db/user_agents"                     => "#{shared_path}/user_agents",
      "#{release_path}/db/archive"                         => "#{shared_path}/archive",
    }
    # Copy across the example database configuration file if there isn't already one
    run "test -f #{shared_path}/database.yml || cp #{release_path}/config/database.yml #{shared_path}/database.yml"
    run "test -f #{shared_path}/production.rb || cp #{release_path}/config/environments/production.rb #{shared_path}/production.rb"
    run "test -d #{shared_path}/emails || mkdir -p #{shared_path}/emails"
    run "test -d #{shared_path}/user_agents || mkdir -p #{shared_path}/user_agents"
    # "ln -sf <a> <b>" creates a symbolic link but deletes <b> if it already exists
    run links.map {|a| "ln -sf #{a.last} #{a.first}"}.join(";")
  end

end

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export, roles: :app do
    #run "cd #{current_path} && sudo bundle exec foreman export upstart /etc/init -a #{application} -u #{user} -l #{shared_path}/log -f Procfile.production"
    run "cd #{current_path} && sudo /usr/local/lib/rvm/wrappers/default/bundle exec foreman export upstart /etc/init -a #{application} -u #{user} -l #{shared_path}/log -f Procfile.production"
  end

  desc "Start the application services"
  task :start, roles: :app do
    sudo "service #{application} start"
  end

  desc "Stop the application services"
  task :stop, roles: :app do
    sudo "service #{application} stop"
  end

  desc "Restart the application services"
  task :restart, roles: :app do
    run "sudo service #{application} restart"
  end
end
