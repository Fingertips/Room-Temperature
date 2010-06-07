require File.expand_path('../../test_helper', __FILE__)

describe Standing do
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
  
  it "returns the last intervals" do
    now = Time.now.to_i
    n = 10
    
    last_intervals = Standing.last_intervals(n)
    last_intervals.first.should <= now
    last_intervals.first.should >= (now - (now % 60))
    (last_intervals.first - last_intervals.second).should == 60
    
    last_intervals.length.should == n
  end
  
  it "returns the latest standings" do
    Standing.stubs(:last_intervals).with(5).returns([1275904980, 1275904920, 1275904860, 1275904800, 1275904740])
    Standing.latest(5).should == {
      'intent'  => 'replace',
      'minutes' => [
        {"timestamp"=>1275904980, "stars"=>[0.02, 0.12, 0.0, 0.02, 0.85]},
        {"timestamp"=>1275904920, "stars"=>[0.03, 0.93, 0.0, 0.03, 0.0]},
        {"timestamp"=>1275904860, "stars"=>[0.28, 0.38, 0.0, 0.28, 0.05]},
        {"timestamp"=>1275904800, "stars"=>[0.0, 0.85, 0.0, 0.0, 0.1]},
        {"timestamp"=>1275904740, "stars"=>[0.0, 0.0, 0.0, 0.0, 0.85]}
      ]
    }
  end
end