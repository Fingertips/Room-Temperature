class Room < ActiveRecord::Base
  has_many :votes do
    def find_in_interval(end_interval, begin_interval)
      find(:all, :conditions => ['votes.timestamp <= ? AND votes.timestamp > ?', end_interval, begin_interval])
    end
    
    def find_in_interval_with_client_token(begin_interval, end_interval, client_token)
      find(:all, :conditions => ['votes.client_token = ? AND votes.timestamp <= ? AND votes.timestamp > ?', client_token, begin_interval, end_interval])
    end
  end
  
  def standing(client_token)
    Standing.new(:room => self, :client_token => client_token)
  end
  
  validates_presence_of :title, :slug
end
