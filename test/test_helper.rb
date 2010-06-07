ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

require 'mocha'
require 'test/spec'
require 'test/spec/rails'
require 'test/spec/rails/macros'
require 'test/spec/share'
require 'test/spec/add_allow_switch'

require 'ostruct'

Net::HTTP.add_allow_switch :start
TCPSocket.add_allow_switch :open

ActionMailer::Base.default_url_options[:host] = 'test.host'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
end
