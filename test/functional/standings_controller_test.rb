require File.expand_path('../../test_helper', __FILE__)

describe "On the", StandingsController, "a visitor" do
  it "sees the complete UI for a room" do
    get :index, :slug => 'nsconf'
    status.should.be :ok
    template.should.be 'standings/index'
    assert_select 'form'
  end
  
  it "sees the latest standings in JSON for a room" do
    get :show, :room_id => rooms(:nsconf).to_param, :format => 'json'
    status.should.be :ok
    response.content_type.should == 'application/json'
    JSON.parse(response.body).should == rooms(:nsconf).standing(nil).latest
  end
end