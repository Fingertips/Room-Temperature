require 'active_support/core_ext'

class Standing
  INTERVAL_LENGTH = 60
  
  def self.latest(n=10)
    minutes = (last_intervals(n).map do |timestamp|
      on(timestamp)
    end)
    { 'intent' => 'replace', 'minutes' => minutes }
  end
  
  def self.last_intervals(n=10)
    begin_last_interval = Time.now.to_i
    begin_last_interval -= begin_last_interval % INTERVAL_LENGTH
    (0..(n-1)).map { |offset| begin_last_interval - (offset * INTERVAL_LENGTH) }
  end
  
  def self.on(timestamp)
    stars = [
      [0, 0.85],
      [1, 0.10],
      [2, 0.05]
    ].inject([0, 0, 0, 0, 0]) do |stars, (offset, weight)|
      votes = Vote.find_in_interval(timestamp - (offset * INTERVAL_LENGTH))
      votes.each do |vote|
        stars[vote.stars-1] += (1.0 / votes.length) * weight
      end
      stars
    end
    {
      'stars'     => stars.map { |star| (star * 100.0).round / 100.0 },
      'timestamp' => timestamp
    }
  end
end