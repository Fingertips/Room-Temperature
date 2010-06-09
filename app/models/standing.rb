require 'memcache' rescue nil

class Standing
  class FakeCache
    def get(*) end
    def add(*) end
  end
  
  class << self; attr_accessor :_cache end
  
  INTERVAL_LENGTH = 60
  MAX_UPDATES     = 180
  
  def initialize(attributes={})
    @room = attributes[:room]
    @client_token = attributes[:client_token]
  end
  
  def self.cache
    unless Rails.env == 'test'
      if @_cache.nil?
        begin
          @_cache = MemCache.new('127.0.0.1', :namespace => 'room-temperature')
          @_cache.get('test')
        rescue MemCache::MemCacheError => e
          Rails.logger.info("  MEMCACHE: #{e.message}")
          @_cache = FakeCache.new
        end
      end; @_cache
    else
      @_cache ||= FakeCache.new
    end
  end
  
  def self.discretize(timestamp)
    timestamp - (timestamp % INTERVAL_LENGTH)
  end
  
  def merge_client_votes(updates)
    if @client_token and !updates.empty? and !updates['minutes'].empty?
      end_interval   = updates['minutes'].first['timestamp'] + INTERVAL_LENGTH
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
  
  def self.on(room, timestamp, recurse=6)
    minute     = nil
    minute_key = [room.slug, timestamp].join(':')
    unless minute = cache.get(minute_key)
      previous_minute = (recurse > 0) ? on(room, timestamp - INTERVAL_LENGTH, recurse-1) : nil
      end_interval    = timestamp - INTERVAL_LENGTH
      votes           = room.votes.find_in_interval(timestamp, end_interval)
      stars = votes.inject([0.0,0.0,0.0,0.0,0.0]) do |stars, vote|
        stars[vote.stars-1] += (1.0 / votes.length); stars
      end
      stars.each_with_index do |star, index|
        if previous_minute
          new_star = (star*0.5 + previous_minute['stars'][index]*0.5)
          stars[index] = (new_star < 0.01) ? 0 : new_star.round(2)
        else
          stars[index] = star.round(2)
        end
      end
      minute = { 'timestamp' => timestamp, 'stars' => stars }
      cache.add(minute_key, minute, 10.minutes)
    end
    minute
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
    first_interval = last_interval() - (MAX_UPDATES * INTERVAL_LENGTH)
    (0..MAX_UPDATES).map { |offset| first_interval + (offset * INTERVAL_LENGTH) }
  end
  
  def latest
    minutes = []
    self.class.last_intervals.each do |timestamp|
      current = self.class.on(@room, timestamp)
      unless minutes.empty? and (current['stars'] == [0.0,0.0,0.0,0.0,0.0])
        minutes << current
      end
    end
    merge_client_votes({ 'intent' => 'replace', 'minutes' => minutes.reverse })
  end
end