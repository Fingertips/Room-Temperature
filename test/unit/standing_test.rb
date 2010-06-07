require File.expand_path('../../test_helper', __FILE__)

describe Standing do
  it "returns intervals since a certain timestamp" do
    Standing.stubs(:end_last_interval).returns(1275909240)
    Standing.intervals_since(1275909000).should == [
      1275909240,
      1275909180,
      1275909120,
      1275909060
    ]
  end
  
  it "should never return more than the maximum intervals" do
    intervals = Standing.intervals_since(100)
    intervals.length.should == Standing::MAX_UPDATES
  end
  
  it "returns updates with the clients votes when a client token was passed" do
    Standing.stubs(:intervals_since).returns([1275904980, 1275904920, 1275904860, 1275904800, 1275904740])
    updates = Standing.since('timestamp', 'RzHeQoof')
    updates.should == {
      'minutes' => [
        {"timestamp"=>1275904980, "stars"=>[0.02, 0.12, 0.0, 0.02, 0.85]},
        {"timestamp"=>1275904920, "stars"=>[0.03, 0.93, 0.0, 0.03, 0.0], "user"=>2},
        {"timestamp"=>1275904860, "stars"=>[0.28, 0.38, 0.0, 0.28, 0.05], "user"=>2},
        {"timestamp"=>1275904800, "stars"=>[0.0, 0.85, 0.0, 0.0, 0.1]},
        {"timestamp"=>1275904740, "stars"=>[0.0, 0.0, 0.0, 0.0, 0.85], "user"=>5}
      ]
    }
  end
  
  it "returns the intent to update all votes when the timestamp was too old" do
    updates = Standing.since(100)
    updates.should.has_key('intent')
    updates['intent'].should == 'replace'
  end
  
  it "returns the standing on a certain timestamp" do
    Standing.on(1275904980).should == {
      'stars'     => [0.02, 0.12, 0.0, 0.02, 0.85],
      'timestamp' => 1275904980
    }
    Standing.on(1275904920).should == {
      'stars'     => [0.03, 0.93, 0.0, 0.03, 0.0],
      'timestamp' => 1275904920
    }
  end
  
  it "returns the end of the last interval" do
    Standing.end_last_interval.should <= Time.now.to_i
    Standing.end_last_interval.should >= (Time.now.to_i - 60)
  end
  
  it "returns the last intervals" do
    Standing.stubs(:end_last_interval).returns(1275913120)
    Standing.last_intervals(5).should == [
      1275913120,
      1275913060,
      1275913000,
      1275912940,
      1275912880
    ]
  end
  
  it "returns the latest standings" do
    Standing.stubs(:last_intervals).with(5).returns([1275904980, 1275904920, 1275904860, 1275904800, 1275904740])
    Standing.latest(5, 'RzHeQoof').should == {
      'intent'  => 'replace',
      'minutes' => [
        {"timestamp"=>1275904980, "stars"=>[0.02, 0.12, 0.0, 0.02, 0.85]},
        {"timestamp"=>1275904920, "stars"=>[0.03, 0.93, 0.0, 0.03, 0.0], "user"=>2},
        {"timestamp"=>1275904860, "stars"=>[0.28, 0.38, 0.0, 0.28, 0.05], "user"=> 2},
        {"timestamp"=>1275904800, "stars"=>[0.0, 0.85, 0.0, 0.0, 0.1]},
        {"timestamp"=>1275904740, "stars"=>[0.0, 0.0, 0.0, 0.0, 0.85], "user"=>5}
      ]
    }
  end
end