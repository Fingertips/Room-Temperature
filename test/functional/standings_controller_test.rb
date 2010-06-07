require File.expand_path('../../test_helper', __FILE__)

describe "On the", StandingsController, "a visitor" do
  it "sees the complete UI" do
    get :index
    status.should.be :ok
    template.should.be 'standings/index'
    assert_select 'form'
  end
end