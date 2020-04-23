require File.expand_path(File.join(File.dirname(__FILE__), '../lib/debitech_soap'))

class MockSoapResult
  class MockReturn
    def method_missing(*opts)
      SOAP::Mapping::Object.new
    end
  end

  def return
    @return ||= MockReturn.new
  end
end

class MockSoapResultRuby19
  class MockReturn < MockSoapResult::MockReturn; end

  def m_return
    @return ||= MockReturn.new
  end
end

RSpec.describe DebitechSoap::API do
  # When it can't find the wsdl file it throws an error. We need to ensure
  # it can find the file (fixed regression bug).
  it "can be initialized" do
    DebitechSoap::API.new
  end
end

RSpec.describe DebitechSoap::API, "valid_credentials?" do

  before do
    @client = double('client')
    SOAP::WSDLDriverFactory.stub(:new).and_return(double('a-factory', :create_rpc_driver => @client))
  end

  it "should call 'refund' with the credentials and dummy values, returning true if we were authed but failed to refund" do
    @client.should_receive(:refund).with(:shopName => "merchant_name", :userName => "api_user_name",
                                                     :password => "api_user_password", :verifyID => -1, :amount => 0).
                                                     and_return(double('refund', :return => double('return', :resultText => "error_transID_or_verifyID")))

    api = DebitechSoap::API.new(:merchant => "merchant_name", :username => "api_user_name", :password => "api_user_password")

    expect(api.valid_credentials?).to eq true
  end

  it "should return false if the service returns an auth error" do
    expect(@client).to receive(:refund).and_return(double('refund', :return => double('return', :resultText => "336 web_service_login_failed")))
    api = DebitechSoap::API.new(:merchant => "merchant_name", :username => "api_user_name", :password => "api_user_password")

    expect(api.valid_credentials?).to eq false
  end

  it "raises if the service returns an unexpected result" do
    expect(@client).to receive(:refund).and_return(double('refund', :return => double('return', :resultText => "let's have lunch")))
    api = DebitechSoap::API.new(:merchant => "merchant_name", :username => "api_user_name", :password => "api_user_password")

    expect { api.valid_credentials? }.to raise_error(%{Unexpected result text: "let's have lunch"})
  end

  it "should work with Ruby 1.9 SOAP API" do
    expect(@client).to receive(:refund).and_return(double('refund', :m_return => double('m_return', :resultText => "error_transID_or_verifyID")))
    api = DebitechSoap::API.new

    expect(api.valid_credentials?).to eq true
  end

end

RSpec.describe DebitechSoap::API, "calling a method with java-style arguments" do

  before do
    @client = double('client')

    expect(SOAP::WSDLDriverFactory).to receive(:new).and_return(double('a-factory', :create_rpc_driver => @client))
  end

  it "should map the arguments to a hash and call the corresponding SOAP method" do
    api = DebitechSoap::API.new(:merchant => "merchant_name", :username => "api_user_name", :password => "api_user_password")
    expect(@client).to receive("refund").with(:verifyID => 1234567, :transID => 23456, :amount => 100, :extra => "extra",
                                          :shopName => "merchant_name", :userName => "api_user_name", :password => "api_user_password").
                                          and_return(MockSoapResult.new)
    api.refund(1234567, 23456, 100, "extra")
  end

  it "should camel case method names" do
    api = DebitechSoap::API.new(:merchant => "merchant_name", :username => "api_user_name", :password => "api_user_password")
    expect(@client).to receive("authorize3DS").with(:verifyID => 1234567, :paRes => "RES", :extra => "extra",
                                          :shopName => "merchant_name", :userName => "api_user_name", :password => "api_user_password").
                                          and_return(MockSoapResult.new)
    api.authorize_3ds(1234567, "RES", "extra")
  end

  it "should not keep old attributes when making subsequent api calls" do
    api = DebitechSoap::API.new(:merchant => "merchant_name", :username => "api_user_name", :password => "api_user_password")
    expect(@client).to receive("refund").with(:verifyID => 1234567, :transID => 23456, :amount => 100, :extra => "extra",
                                          :shopName => "merchant_name", :userName => "api_user_name", :password => "api_user_password").
                                          and_return(MockSoapResult.new)
    expect(@client).to receive("authorize3DS").with(:verifyID => 1234567, :paRes => "RES", :extra => "extra",
                                          :shopName => "merchant_name", :userName => "api_user_name", :password => "api_user_password").
                                          and_return(MockSoapResult.new)

    api.refund(1234567, 23456, 100, "extra")
    api.authorize3DS(1234567, "RES", "extra")
  end

  it "should create a return object" do
    api = DebitechSoap::API.new
    mock_soap_result = MockSoapResult.new
    expect(mock_soap_result.return).to receive(:resultText).and_return("success")
    expect(@client).to receive(:refund).and_return(mock_soap_result)

    expect(api.refund(1234567, 23456, 100, "extra").resultText).to eq "success"
  end

  it "should return nil when there is no data" do
    api = DebitechSoap::API.new
    mock_soap_result = MockSoapResult.new
    expect(@client).to receive(:refund).and_return(mock_soap_result)

    expect(api.refund(1234567, 23456, 100, "extra").resultCode).to be_nil
  end

  it "should be able to access the data using getCamelCase, get_underscore and underscore methods" do
    api = DebitechSoap::API.new
    mock_soap_result = MockSoapResult.new
    expect(mock_soap_result.return).to receive(:resultText).and_return("success")
    expect(@client).to receive(:refund).and_return(mock_soap_result)

    result = api.refund(1234567, 23456, 100, "extra")

    expect(result.getResultText).to eq "success"
    expect(result.get_result_text).to eq "success"
    expect(result.result_text).to eq 'success'
  end

  it "should convert the result to an integer when its a number" do
    api = DebitechSoap::API.new
    mock_soap_result = MockSoapResult.new
    expect(mock_soap_result.return).to receive(:resultCode).and_return("100")

    expect(@client).to receive(:refund).and_return(mock_soap_result)

    result = api.refund(1234567, 23456, 100, "extra")
    expect(result.resultCode).to eq 100
    expect(result.getResultCode).to eq 100
    expect(result.get_result_code).to eq 100
  end

  it "should convert the result to an integer when its zero" do
    api = DebitechSoap::API.new
    mock_soap_result = MockSoapResult.new
    expect(mock_soap_result.return).to receive(:resultCode).and_return("0")
    expect(@client).to receive(:refund).and_return(mock_soap_result)

    result = api.refund(1234567, 23456, 100, "extra")

    expect(result.resultCode).to eq 0
  end

  it "should work with Ruby 1.9 SOAP API" do
    api = DebitechSoap::API.new
    mock_soap_result = MockSoapResultRuby19.new
    expect(mock_soap_result.m_return).to receive(:resultCode).and_return("0")
    expect(@client).to receive(:refund).and_return(mock_soap_result)

    result = api.refund(1234567, 23456, 100, "extra")

    expect(result.resultCode).to eq 0
  end
end

RSpec.describe DebitechSoap::API, "calling a method with hash-style arguments" do

  before do
    @client = double('client')
    expect(SOAP::WSDLDriverFactory).to receive(:new).and_return(double('factory', :create_rpc_driver => @client))
  end

  it "should call the corresponding soap method" do
    api = DebitechSoap::API.new(:merchant => "merchant_name", :username => "api_user_name", :password => "api_user_password")
    expect(@client).to receive("refund").with(:verifyID => 1234567, :transID => 23456, :amount => 100, :extra => "extra",
                                          :shopName => "merchant_name", :userName => "api_user_name", :password => "api_user_password").
                                          and_return(MockSoapResult.new)
    api.refund(:verifyID => 1234567, :transID => 23456, :amount => 100, :extra => "extra")
  end

  it "should return data" do
    api = DebitechSoap::API.new
    mock_soap_result = MockSoapResult.new
    expect(mock_soap_result.return).to receive(:resultText).and_return("success")
    expect(@client).to receive("refund").and_return(mock_soap_result)

    expect(api.refund(:verifyID => 1234567, :transID => 23456, :amount => 100, :extra => "extra").getResultText).to eq "success"
  end

  it "should work with Ruby 1.9 SOAP API" do
    api = DebitechSoap::API.new
    mock_soap_result = MockSoapResultRuby19.new
    expect(mock_soap_result.m_return).to receive(:resultText).and_return("success")
    expect(@client).to receive(:refund).and_return(mock_soap_result)

    result = api.refund(:verifyID => 1234567, :transID => 23456, :amount => 100, :extra => "extra")

    expect(result.getResultText).to eq "success"
  end
end

RSpec.describe DebitechSoap::API, "handling exceptions" do

  before do
    @client = double
    expect(SOAP::WSDLDriverFactory).to receive(:new).and_return(double('factory', :create_rpc_driver => @client))
  end

  it "should catch Timeout::Error and return 403" do
    api = DebitechSoap::API.new
    expect(@client).to receive(:refund).and_raise(Timeout::Error)
    result = api.refund(:verifyID => 1234567, :transID => 23456, :amount => 100, :extra => "extra")

    expect(result.getResultCode).to eq 403
    expect(result.getResultText).to eq "SOAP Timeout"
  end
end

RSpec.describe DebitechSoap::API, "overriding ciphers with ENV" do
  around do |example|
    old_env = ENV["DIBS_HTTPCLIENT_CIPHERS"]
    ENV["DIBS_HTTPCLIENT_CIPHERS"] = "FOO"
    example.run
    ENV["DIBS_HTTPCLIENT_CIPHERS"] = old_env
  end

  it "changes the configured HTTPClient ciphers" do
    api = DebitechSoap::API.new

    httpclient = api.instance_variable_get("@client").streamhandler.client

    expect(httpclient).to be_instance_of HTTPClient
    expect(httpclient.ssl_config.ciphers).to eq "FOO"
  end
end
