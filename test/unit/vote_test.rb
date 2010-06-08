require File.expand_path('../../test_helper', __FILE__)

describe Vote do
  it "generates an unused token" do
    client_token = Vote.unused_client_token
    Vote.find_by_client_token(client_token).should == nil
  end
  
  it "generates different tokens each time" do
    client_token1 = Vote.unused_client_token
    client_token2 = Vote.unused_client_token
    client_token1.should.not == client_token2
  end
  
  it "sets a timestamp when saving the vote" do
    vote = Vote.new(:room_id => 1, :stars => 3, :client_token => 'adE1Ie7C')
    vote.timestamp.should.be.nil
    vote.save!
    vote.timestamp.should.not.be.nil
  end
end

describe Vote, "concerning validation" do
  it "is invalid without a client token, value, and room id" do
    vote = Vote.create
    vote.errors[:stars].should.not.be.blank
    vote.errors[:client_token].should.not.be.blank
    vote.errors[:room_id].should.not.be.blank
  end
end