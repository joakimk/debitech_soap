require 'soap/wsdlDriver'

module DebitechSoap
  class API

    RETURN_DATA = %w{aCSUrl acquirerAddress acquirerAuthCode acquirerAuthResponseCode acquirerCity acquirerConsumerLimit acquirerErrorDescription acquirerFirstName acquirerLastName acquirerMerchantLimit acquirerZipCode amount errorMsg infoCode infoDescription pAReqMsg resultCode resultText verifyID}

    def initialize(opts = {})
      @api_credentials = opts
      disable_stderr do
        @client = SOAP::WSDLDriverFactory.new('https://secure.incab.se/axis2/services/DTServerModuleService_v1?wsdl').create_rpc_driver
      end
    end

    def valid_credentials?
      disable_stderr do
        @client.checkSwedishPersNo(@api_credentials.merge({ :persNo => "555555-5555" })).return == "true"
      end
    end

  private

    def disable_stderr
      begin
        $stderr = File.open('/dev/null', 'w')
        yield
      ensure
        $stderr = STDERR
      end
    end

  end
end
