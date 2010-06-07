require 'active_support/core_ext'

class Standing
  INTERVAL_LENGTH = 60
  MAX_UPDATES     = 180
  
  def self.since(timestamp, client_token=nil)
    minutes = (intervals_since(timestamp).map do |timestamp|
      on(timestamp, client_token)
    end)
    
    updates = { 'minutes' => minutes }
    updates['intent'] = 'replace' if minutes.length == MAX_UPDATES
    updates
  end
  
  def self.intervals_since(timestamp)
    begin_first_interval = timestamp - (timestamp % INTERVAL_LENGTH)
    current              = end_last_interval()
    
    since = []
    while(current >= begin_first_interval and since.length < MAX_UPDATES)
      since << current
      current -= INTERVAL_LENGTH
    end
    since
  end
  
  def self.latest(n=10, client_token=nil)
    minutes = (last_intervals(n).map do |timestamp|
      on(timestamp, client_token)
    end)
    { 'intent' => 'replace', 'minutes' => minutes }
  end
  
  def self.end_last_interval
    end_last_interval = Time.now.to_i
    end_last_interval - (end_last_interval % INTERVAL_LENGTH)
  end
  
  def self.last_intervals(n=10)
    end_last_interval = end_last_interval()
    (0..(n-1)).map { |offset| end_last_interval - (offset * INTERVAL_LENGTH) }
  end
  
  def self.on(timestamp, client_token=nil)
    user = nil
    stars = [[0, 0.85],[1, 0.10],[2, 0.05]].inject([0, 0, 0, 0, 0]) do |stars, (offset, weight)|
      votes = Vote.find_in_interval(timestamp - (offset * INTERVAL_LENGTH))
      votes.each do |vote|
        if offset == 0 and vote.client_token == client_token
          user = vote.stars
        end
        stars[vote.stars-1] += (1.0 / votes.length) * weight
      end
      stars
    end
    on = { 'stars'     => stars.map { |star| (star * 100.0).round / 100.0 },
           'timestamp' => timestamp }
    on['user'] = user if user
    on
  end
  
  def self.max_updates
    MAX_UPDATES
  end
end