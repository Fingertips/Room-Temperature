class Vote < ActiveRecord::Base
  belongs_to :room
  
  before_save :set_timestamp
  
  def set_timestamp
    self.timestamp = Time.now.to_i
  end
  
  def self.unused_client_token
    client_token = nil
    until !client_token.blank? and find_by_client_token(client_token).nil?
      client_token = Token.generate(8, :with_numbers => true)
    end
    client_token
  end
  
  validates_inclusion_of :stars, :in => 1..5, :message => 'should be 1, 2, 3, 4, or 5'
  validates_presence_of :client_token, :room_id
end
