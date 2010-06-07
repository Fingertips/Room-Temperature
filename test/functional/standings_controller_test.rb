require File.expand_path('../../test_helper', __FILE__)

describe "On the", StandingsController, "a visitor" do
  it "sees the complete UI" do
    get :index
    status.should.be :ok
    template.should.be 'standings/index'
    assert_select 'form'
  end
  
  it "sees the latest standings in json" do
    get :show, :format => 'json'
    status.should.be :ok
    response.content_type.should == 'application/json'
    JSON.parse(response.body).should == Standing.latest(50)
  end
end