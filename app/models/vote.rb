class Vote < ActiveRecord::Base
  validates_presence_of :value
  validates_presence_of :client_token
end
