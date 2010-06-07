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
end

describe Vote, "concerning validation" do
  it "is invalid without a client token and value" do
    vote = Vote.create
    vote.errors[:stars].should.not.be.blank
    vote.errors[:client_token].should.not.be.blank
  end
end