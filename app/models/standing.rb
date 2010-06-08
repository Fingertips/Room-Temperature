require 'active_support/core_ext'

class Standing
  INTERVAL_LENGTH = 60
  MAX_UPDATES     = 180
  
  def initialize(attributes={})
    @room = attributes[:room]
    @client_token = attributes[:client_token]
  end
  
  def self.discretize(timestamp)
    timestamp - (timestamp % INTERVAL_LENGTH)
  end
  
  def merge_client_votes(updates)
    if @client_token
      end_interval   = updates['minutes'].first['timestamp']
      begin_interval = updates['minutes'].last['timestamp']
      yours = @room.votes.find_in_interval_with_client_token(end_interval, begin_interval, @client_token).inject({}) do |yours, vote|
        yours[self.class.discretize(vote.timestamp)] = vote.stars
        yours
      end
      yours.empty? ? updates : updates.merge('yours' => yours)
    else
      updates
    end
  end
  
  def self.last_interval
    discretize(Time.now.to_i)
  end
  
  def self.intervals_since(timestamp)
    since          = []
    current        = last_interval()
    first_interval = discretize(timestamp)
    while(current > first_interval and since.length < MAX_UPDATES)
      since << current
      current -= INTERVAL_LENGTH
    end
    since
  end
  
  def self.on(room, timestamp)
    stars = [[0,0.56],[1,0.33],[2,0.11]].inject([0,0,0,0,0]) do |stars, (offset, weight)|
      begin_interval = timestamp - (offset * INTERVAL_LENGTH)
      end_interval   = begin_interval - INTERVAL_LENGTH
      votes          = room.votes.find_in_interval(begin_interval, end_interval)
      votes.each do |vote|
        stars[vote.stars-1] += (1.0 / votes.length) * weight
      end
      stars
    end
    { 'timestamp' => timestamp, 'stars' => stars.map { |star| (star * 100.0).round / 100.0 } }
  end
  
  def since(timestamp)
    minutes = (self.class.intervals_since(timestamp).map do |timestamp|
      self.class.on(@room, timestamp)
    end)
    updates = { 'minutes' => minutes }
    updates['intent'] = 'replace' if minutes.length == MAX_UPDATES
    merge_client_votes(updates)
  end
  
  def self.last_intervals
    last_interval = last_interval()
    (0..MAX_UPDATES-1).map { |offset| last_interval - (offset * INTERVAL_LENGTH) }
  end
  
  def latest
    minutes = (self.class.last_intervals.map do |timestamp|
      self.class.on(@room, timestamp)
    end)
    merge_client_votes({ 'intent' => 'replace', 'minutes' => minutes })
  end
end