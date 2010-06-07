require File.expand_path('../../test_helper', __FILE__)

describe "Token" do
  it "should generate a token" do
    Token.generate.should.not.be.blank
  end
  
  it "should not generate the same token twice in quick succession" do
    Token.generate.should.not == Token.generate
  end
  
  it "should generate tokens of specific lengths" do
    Token.generate(3).length.should == 3
    Token.generate(40).length.should == 40
    Token.generate(61).length.should == 61
  end
  
  it "should generate upcased tokens when asked" do
    Token.generate(100, :upcase => true).should =~ /^[A-Z]{100}$/
  end
  
  it "should generate tokens with numbers in them when asked" do
    Token.generate(100, :with_numbers => true).should =~ /[0-9]/
  end
  
  it "should generate tokens with only numbers in them when asked" do
    Token.generate(100, :with_numbers => true, :with_characters => false).should =~ /^[0-9]{100}$/
  end
  
  it "should raise an exception when there is no domain to generate from" do
    lambda {
      Token.generate(1, :with_characters => false, :with_numbers => false)
    }.should.raise(ArgumentError)
  end
end