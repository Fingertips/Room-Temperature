require File.expand_path('../../test_helper', __FILE__)

describe Room do
  it "returns a standing object for itself" do
    room = rooms(:nsconf)
    room.standing('RzHeQoof').should.be.kind_of?(Standing)
  end
end