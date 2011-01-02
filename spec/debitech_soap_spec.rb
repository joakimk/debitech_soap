require File.expand_path(File.join(File.dirname(__FILE__), '../lib/debitech_soap'))

describe DebitechSoap::API, "valid_credentials?" do
  
  before do
    @client = mock(Object)
    SOAP::WSDLDriverFactory.stub!(:new).and_return(mock(Object, :create_rpc_driver => @client))
  end

  it "should call checkSwedishPersNo with the credentials and a valid swedish social security number" do
    @client.should_receive(:checkSwedishPersNo).with(:shopName => "merchant_name", :userName => "api_user_name",
                                                     :password => "api_user_password", :persNo => "555555-5555").
                                                     and_return(mock(Object, :return => "true"))

    api = DebitechSoap::API.new(:shopName => "merchant_name", :userName => "api_user_name", :password => "api_user_password")
    api.valid_credentials?.should == true
  end

  it "should return false if the service returns false" do
    @client.stub!(:checkSwedishPersNo).and_return(mock(Object, :return => "false"))
    api = DebitechSoap::API.new(:shopName => "merchant_name", :userName => "api_user_name", :password => "api_user_password")
    api.valid_credentials?.should == false
  end

end
