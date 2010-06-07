require File.expand_path('../../test_helper', __FILE__)

describe "On the", VotesController, "a visitor" do
  it "submits a vote" do
    lambda {
      post :create, :stars => 2
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
      post :create, {:stars => 3}
    }.should.differ('Vote.count', +1)
    status.should.be :created
    
    assigns(:vote).client_token.should == client_token
  end
  
  it "sees new standings when submitting a timestamp along with the vote" do
    lambda {
      post :create, {:stars => 3, :since => (Standing.end_last_interval - 120)}
    }.should.differ('Vote.count', +1)
    status.should.be :created
    standing = JSON.parse(response.body)
    standing.should.has_key?('minutes')
    standing['minutes'].length.should == 2
  end
  
  it "shows validations errors when the vote is not valid" do
    lambda {
      post :create
    }.should.not.differ('Vote.count')
    status.should.be :ok
    JSON.parse(response.body).should == [["stars", "should be 1, 2, 3, 4, or 5"]]
  end
end