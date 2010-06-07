require File.expand_path('../../test_helper', __FILE__)

describe Vote, "concerning validation" do
  it "is invalid without a client token and value" do
    vote = Vote.create
    vote.errors[:value].should.not.be.blank
    vote.errors[:client_token].should.not.be.blank
  end
end