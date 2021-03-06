require File.expand_path('../../test_helper', __FILE__)

describe Standing, "when no client token is set" do
  before do
    @standing = Standing.new(:room => rooms(:nsconf))
  end
  
  it "returns an update of minutes since a certain timestamp" do
    Standing.stubs(:last_interval).returns(1275905040)
    @standing.since(1275904740).should == {
      'minutes' => [
        { 'timestamp' => 1275905040, 'stars' => [0.03, 0.18, 0, 0.03, 0.27]   },
        { 'timestamp' => 1275904980, 'stars' => [0.05, 0.36, 0, 0.05, 0.54] },
        { 'timestamp' => 1275904920, 'stars' => [0.09, 0.71, 0, 0.09, 0.07]  },
        { 'timestamp' => 1275904860, 'stars' => [0.17, 0.42, 0, 0.17, 0.13] },
        { 'timestamp' => 1275904800, 'stars' => [0, 0.5, 0, 0, 0.25       ]   }
      ]
    }
  end
  
  it "returns the latest minutes" do
    Standing.stubs(:last_interval).returns(1275905040)
    latest = @standing.latest
    
    latest.should.has_key('minutes')
    latest['minutes'].length.should == 6 # Only six actually contain data
    
    latest['minutes'][0,2].should == [
      { 'timestamp' => 1275905040, 'stars' => [0.03, 0.18, 0, 0.03, 0.27] },
      { 'timestamp' => 1275904980, 'stars' => [0.05, 0.36, 0, 0.05, 0.54]  }
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
        { 'timestamp' => 1275905040, 'stars' => [0.03, 0.18, 0, 0.03, 0.27]   },
        { 'timestamp' => 1275904980, 'stars' => [0.05, 0.36, 0, 0.05, 0.54] },
        { 'timestamp' => 1275904920, 'stars' => [0.09, 0.71, 0, 0.09, 0.07]  },
        { 'timestamp' => 1275904860, 'stars' => [0.17, 0.42, 0, 0.17, 0.13] },
        { 'timestamp' => 1275904800, 'stars' => [0, 0.5, 0, 0, 0.25       ]   }
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
    latest['minutes'].length.should == 6 # Only six actually contain data
    
    latest['minutes'][0,2].should == [
      { 'timestamp' => 1275905040, 'stars' => [0.03, 0.18, 0, 0.03, 0.27] },
      { 'timestamp' => 1275904980, 'stars' => [0.05, 0.36, 0, 0.05, 0.54]  }
    ]
    
    latest['yours'].should == { 1275904860 => 2, 1275904800 => 2 }
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
      'stars'     => [0.05, 0.36, 0, 0.05, 0.54],
      'timestamp' => 1275904980
    }
    Standing.on(rooms(:nsconf), 1275904920).should == {
      'stars'     => [0.09, 0.71, 0, 0.09, 0.07],
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
      1275902320, 1275902380, 1275902440, 1275902500, 1275902560
    ]
    
  end
end