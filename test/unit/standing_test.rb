require File.expand_path('../../test_helper', __FILE__)

describe Standing, "when no client token is set" do
  before do
    @standing = Standing.new(:room => rooms(:nsconf))
  end
  
  it "returns an update of minutes since a certain timestamp" do
    Standing.stubs(:last_interval).returns(1275905040)
    @standing.since(1275904740).should == {
      'minutes' => [
        { 'timestamp' => 1275905040, 'stars' => [0.0, 0.11, 0.0, 0.0, 0.33]   },
        { 'timestamp' => 1275904980, 'stars' => [0.04, 0.37, 0.0, 0.04, 0.56] },
        { 'timestamp' => 1275904920, 'stars' => [0.11, 0.78, 0.0, 0.11, 0.0]  },
        { 'timestamp' => 1275904860, 'stars' => [0.19, 0.52, 0.0, 0.19, 0.11] },
        { 'timestamp' => 1275904800, 'stars' => [0.0, 0.56, 0.0, 0.0, 0.33]   }
      ]
    }
  end
  
  it "returns the latest minutes" do
    Standing.stubs(:last_interval).returns(1275905040)
    latest = @standing.latest
    
    latest.should.has_key('minutes')
    latest['minutes'].length.should == Standing::MAX_UPDATES
    
    latest['minutes'][0,2].should == [
      { 'timestamp' => 1275905040, 'stars' => [0.0, 0.11, 0.0, 0.0, 0.33]   },
      { 'timestamp' => 1275904980, 'stars' => [0.04, 0.37, 0.0, 0.04, 0.56] }
    ]
  end
end

describe Standing, "when a the client token is set" do
  before do
    @standing = Standing.new(:room => rooms(:nsconf), :client_token => 'RzHeQoof')
  end
  
  it "returns an update of minutes since a certain timestamp" do
    Standing.stubs(:last_interval).returns(1275905040)
    @standing.since(1275904740).should == {
      'minutes' => [
        { 'timestamp' => 1275905040, 'stars' => [0.0, 0.11, 0.0, 0.0, 0.33]   },
        { 'timestamp' => 1275904980, 'stars' => [0.04, 0.37, 0.0, 0.04, 0.56] },
        { 'timestamp' => 1275904920, 'stars' => [0.11, 0.78, 0.0, 0.11, 0.0]  },
        { 'timestamp' => 1275904860, 'stars' => [0.19, 0.52, 0.0, 0.19, 0.11] },
        { 'timestamp' => 1275904800, 'stars' => [0.0, 0.56, 0.0, 0.0, 0.33]   }
      ],
      'yours' => {
        1275904860 => 2,
        1275904800 => 2
      }
    }
  end
  
  it "returns the latest minutes" do
    Standing.stubs(:last_interval).returns(1275905040)
    latest = @standing.latest
    
    latest.should.has_key('minutes')
    latest['minutes'].length.should == Standing::MAX_UPDATES
    
    latest['minutes'][0,2].should == [
      { 'timestamp' => 1275905040, 'stars' => [0.0, 0.11, 0.0, 0.0, 0.33]   },
      { 'timestamp' => 1275904980, 'stars' => [0.04, 0.37, 0.0, 0.04, 0.56] }
    ]
    
    latest['yours'].should == {1275904680=>5, 1275904860=>2, 1275904800=>2}
  end
end

describe Standing do
  it "returns intervals since a certain timestamp" do
    Standing.stubs(:last_interval).returns(1275909240)
    Standing.intervals_since(1275909000)[0,5].should == [
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
  
  it "returns the intent to update all votes when the timestamp was too old" do
    updates = Standing.new(:room => rooms(:nsconf)).since(100)
    updates.should.has_key('intent')
    updates['intent'].should == 'replace'
  end
  
  it "returns the standing on a certain timestamp" do
    Standing.on(rooms(:nsconf), 1275904980).should == {
      'stars'     => [0.04, 0.37, 0.0, 0.04, 0.56],
      'timestamp' => 1275904980
    }
    Standing.on(rooms(:nsconf), 1275904920).should == {
      'stars'     => [0.11, 0.78, 0.0, 0.11, 0.0],
      'timestamp' => 1275904920
    }
  end
  
  it "returns the end of the last interval" do
    Standing.last_interval.should <= Time.now.to_i
    Standing.last_interval.should >= (Time.now.to_i - 60)
  end
  
  it "returns the last intervals" do
    Standing.stubs(:last_interval).returns(1275913120)
    Standing.last_intervals[0,5].should == [
      1275913120,
      1275913060,
      1275913000,
      1275912940,
      1275912880
    ]
  end
end