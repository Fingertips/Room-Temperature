require File.expand_path('../../test_helper', __FILE__)

describe "On the", VotesController, "a visitor" do
  it "submits a vote" do
    lambda {
      post :create, :room_id => rooms(:nsconf).to_param, :stars => 2
    }.should.differ('Vote.count', +1)
    status.should.be :created
    
    client_token = response.cookies['token']
    client_token.should.not.be.blank
    assigns(:vote).client_token.should == client_token
  end
  
  it "submits a second vote" do
    client_token = votes(:alice_first_vote).client_token
    request.cookies['token'] = client_token
    
    lambda {
      post :create, :room_id => rooms(:nsconf).to_param, :stars => 3
    }.should.differ('Vote.count', +1)
    status.should.be :created
    
    assigns(:vote).client_token.should == client_token
  end
  
  it "sees new standings when submitting a timestamp along with the vote" do
    lambda {
      post :create, :room_id => rooms(:nsconf).to_param, :stars => 3, :since => (Standing.last_interval - 120)
    }.should.differ('Vote.count', +1)
    status.should.be :created
    standing = JSON.parse(response.body)
    standing.should.has_key?('minutes')
    standing['minutes'].length.should == 2
  end
  
  it "shows validations errors when the vote is not valid" do
    lambda {
      post :create, :room_id => rooms(:nsconf).to_param
    }.should.not.differ('Vote.count')
    status.should.be :unprocessable_entity
    JSON.parse(response.body).should == [["stars", "should be 1, 2, 3, 4, or 5"]]
  end
  
  it "sees new standings when creating a vote with timestamp, but without star rating" do
    lambda {
      post :create, :room_id => rooms(:nsconf).to_param, :since => (Standing.last_interval - 120)
    }.should.not.differ('Vote.count')
    status.should.be :ok
    standing = JSON.parse(response.body)
    standing.should.has_key?('minutes')
    standing['minutes'].length.should == 2
  end
  
  it "sees own votes along with the new standings" do
    client_token = votes(:alice_first_vote).client_token
    request.cookies['token'] = client_token
    
    room = rooms(:nsconf)
    vote = room.votes.build(:stars => 2, :client_token => client_token, :timestamp => Standing.last_interval - 100)
    vote.save!
    
    post :create, :room_id => room.to_param, :stars => 3, :since => (Standing.last_interval - 120)
    status.should.be :created
    
    updates = JSON.parse(response.body)
    updates.should.has_key('yours')
  end
end