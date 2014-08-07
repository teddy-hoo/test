# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'newhire'
set :user, 'teddy'
set :scm, :git
set :repo_url, 'https://github.com/teddy-hoo/newhire.git'
set :deploy_to, "/home/teddy/webapp"
set :pty, true

HOME="/home/teddy/"
#set stage
#set :stage, 'production'

#set bundler
set :bundle_roles, :all                                  # this is default
set :bundle_servers, -> { release_roles(fetch(:bundle_roles)) } # this is default
set :bundle_binstubs, -> { shared_path.join('bin') }     # this is default
set :bundle_gemfile, -> { release_path.join('Gemfile') } # default: nil
set :bundle_path, -> { shared_path.join('bundle') }      # this is default
set :bundle_without, %w{development test}.join(' ')      # this is default
set :bundle_flags, '--deployment --quiet'                # this is default
set :bundle_env_variables, {}                    # this is default

#set rbenv
#set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '1.9.3-p484'
#set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{#fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
#set :rbenv_map_bins, %w{rake gem bundle ruby rails}
#set :rbenv_roles, :all # default value



namespace :github do

  desc "configure github environment"
  task :setup do
    email     = Capistrano::CLI.ui.ask("input email address: ")
    file      = "/home/devops/.ssh/id_rsa"
    public_file = "#{file}.pub"
    run "git config --global core.editor 'vi'"
    run "git config --global user.email '#{email}'"
    check = capture "if [ -f #{file} ]; then echo 'true'; fi"
    if check.empty?
      run "ssh-keygen -q -t rsa -C '#{email}' -N '' -f '#{file}'"
    end
    key = capture "cat #{public_file}"
    username  = Capistrano::CLI.ui.ask("input github username: ")
    password  = Capistrano::CLI.password_prompt("input github password: ")
    github = Github.new( login: username, password: password )
    github.users.keys.create( title: "capistrano generated", key: key )
  end

end

namespace :bundle do
  desc 'run bundle isntall'
  task :install do
    on roles(:web) do
      #execute "cd #{current_path} && bundle install"
    end
  end
end

namespace :mongodb do

  desc 'install mongodb'
  task :install do
    #Import the public key used by the package management system
    run 'sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10'
    #Create a list file for MongoDB
    run 'echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"" ' +
      '| sudo tee /etc/apt/sources.list.d/mongodb.list'
    #Reload local package database
    run 'sudo apt-get update'
    #Install the MongoDB packages
    run 'sudo apt-get install mongodb-org'
  end
end

namespace :deploy do

  before "mongodb:install", "bundle:install"
  desc 'setup application'
  task :setup do
    before "bundle:install", "github:setup"
    on roles(:web) do
      execute "cd #{release_path} | bundle install"
      #execute :sudo, 'apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10'
      #Create a list file for MongoDB
      #execute :sudo, 'echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart ' +
      #  'dist 10gen"" | tee /etc/apt/sources.list.d/mongodb.list'
      #Reload local package database
      #execute :sduo, 'apt-get update'
      #Install the MongoDB packages
      #execute :sudo, 'apt-get install mongodb-org'
      execute "echo 'sinatra'"
    end
  end

  desc 'start appliction'
  task :start do
    on roles(:web) do
      #execute "ruby #{release_path}/server.rb"
      #execute :sudo, "echo 'sinatra'"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:web) do
      #execute "pkill ruby"
      #execute "ruby #{release_path}/server.rb"
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

namespace :ruby do

  desc "install rbenv, ruby, and bundler"
  task :setup do
    check = capture "if [ -d #{HOME}/.rbenv ]; then echo 'true'; fi"
    if check.empty?
      run "git clone https://github.com/sstephenson/rbenv.git ~/.rbenv"
    end
    check2 = capture "if [ -f #{HOME}/.bash_profile ]; then echo 'true'; fi"
    if check2.empty?
      #run "echo 'export LC_CTYPE=\"en_US.UTF-8\"' >> #{HOME}/.bash_profile"
      # not needed if you setup ubuntu correctly
    end
    check3 = capture "if grep rbenv #{HOME}/.bash_profile; then echo \"true\"; fi"
    if check3.empty?
      run "echo 'export PATH=\"#{HOME}/.rbenv/bin:$PATH\"' >> #{HOME}/.bash_profile"
      run "echo 'eval \"$(rbenv init -)\"' >> #{HOME}/.bash_profile"
    end
    check4 = capture "if [ -d #{HOME}/.rbenv/plugins/ruby-build ]; then echo 'true'; fi"
    if check4.empty?
      run "git clone https://github.com/sstephenson/ruby-build ~/.rbenv/plugins/ruby-build"
      run "rbenv rehash"
    end
    run "rbenv install #{rbenv_ruby}"
    run "rbenv global #{rbenv_ruby}"
    run "rbenv rehash"
    run "gem install bundler"
    run "rbenv rehash"
  end

end
