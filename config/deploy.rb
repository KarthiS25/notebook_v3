require 'mina/rails'
require 'mina/bundler'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
# require 'mina/rvm'    # for rvm support. (https://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, 'notebook'
set :domain, 'example.com'
set :deploy_to, '/home/karthi/example.com'
set :repository, 'https://github.com/KarthiS25/notebook_v3.git'
set :branch, 'main'

# Optional settings:
set :user, 'karthi'          # Username in the server to SSH to.
set :ssh_options, '-A'
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
# set :shared_dirs, fetch(:shared_dirs, []).push('public/assets')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-2.5.3@default'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.5.3 --skip-existing}
  # command %{rvm install ruby-2.5.3}
  # command %{gem install bundler}
end

task :setup do
  command %[touch "#{fetch(:shared_path)}/config/database.yml"]
  command %[touch "#{fetch(:shared_path)}/config/secrets.yml"]
  command %[touch "#{fetch(:shared_path)}/config/puma.rb"]
  comment "Be sure to edit '#{fetch(:shared_path)}/config/database.yml', 'secrets.yml' and puma.rb."
end

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    comment "Deploying #{fetch(:application_name)} to #{fetch(:domain)}:#{fetch(:deploy_to)}"
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'rvm:load_env_vars'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    command %{#{fetch(:rails)} db:seed}
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'puma:phased_restart'
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
