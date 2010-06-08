require File.expand_path('../../test_helper', __FILE__)

describe "On the", RoomsController, "a visitor" do
  it "sees an overview of all rooms" do
    get :index
    status.should.be :ok
    template.should.be 'rooms/index'
    assert_select 'h1'
  end
end