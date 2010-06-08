load 'deploy'
require 'rubygems'

set :application, "room-temperature"

require 'fingercap/configurations/miller'
set :url, "http://roomte.mp"

set :repository, "git@github.com:Fingertips/Room-Temperature.git"
set :scm, "git"
set :branch, "master"
set :git_shallow_clone, 1

namespace :rt do
  desc "Make sure the app can write its JavaScript cache"
  task :setup_javascript_cache do
    js_cache_dir = "#{current_path}/public/javascripts/cache"
    sudo "rm -rf #{js_cache_dir}"
    sudo "mkdir -p #{js_cache_dir}"
    sudo "chown -R app:wheel #{js_cache_dir}"
  end
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

after "deploy:symlink",    "rt:setup_javascript_cache"