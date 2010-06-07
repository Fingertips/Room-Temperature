load 'deploy'
require 'rubygems'

set :application, "room-temperature"

require 'fingercap/configurations/miller'
set :url, "http://roomte.mp"

set :repository, "git@github.com:Fingertips/Room-Temperature.git"
set :scm, "git"
set :branch, "master"
set :git_shallow_clone, 1

namespace :room_temperature do
end

namespace :deploy do
  desc "Perform a full installation."
  task :install do
    setup
    fix_permissions
    check
    update
  end
end

after "deploy",            "notify:deploy"
after "deploy:migrations", "notify:migrations"