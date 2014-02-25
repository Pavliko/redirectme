require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm'    # for rvm support. (http://rvm.io)
require 'mina_sidekiq/tasks'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)
set :user, 'x5'
set :domain, 'redirectme.ru'
set :deploy_to, '/var/www/redirectme'
set :app_path, [deploy_to, current_path].join(?/)
set :repository, 'git@github.com:vampiroX5/redirectme.git'
set :branch, 'master'
set :rails_env, 'production'
set :sidekiq_pid, [deploy_to, current_path, 'tmp/pids/sidekiq.pid'].join(?/)
set :sidekiq_processes, 1



# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'log']

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]

  %w[
    tmp/pids
    tmp/sockets
    log
    config
  ].each do |path|
    queue %Q| mkdir -p #{deploy_to}/shared/#{path} |
    queue %Q| chmod g+rx,u+rwx #{deploy_to}/shared/#{path} |
  end

  %w[
    config/database.yml
    config/redis.yml
  ].each do |file|
    queue %Q| touch #{deploy_to}/shared/#{file} |
    queue %Q| echo "-----> Be sure to edit 'shared/#{file}'." |
  end
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    # queue %| touch #{deploy_to}/shared/debug |
    # queue %| echo "#{`gem install bundler`}" > #{deploy_to}/shared/debug |

    invoke 'sidekiq:quiet'
    invoke 'git:clone'
    invoke 'deploy:link_shared_paths'
    invoke 'bundle:install'
    invoke 'rails:db_migrate'
    invoke 'rails:assets_precompile'
    invoke 'deploy:cleanup'

    to :launch do
      invoke 'sidekiq:restart'
      queue "touch #{deploy_to}/tmp/restart.txt"
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers

