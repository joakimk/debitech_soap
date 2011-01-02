require 'soap/wsdlDriver'

module DebitechSoap
  class API
    RETURN_DATA = %w{aCSUrl acquirerAddress acquirerAuthCode acquirerAuthResponseCode acquirerCity acquirerConsumerLimit acquirerErrorDescription acquirerFirstName acquirerLastName acquirerMerchantLimit acquirerZipCode amount errorMsg infoCode infoDescription pAReqMsg resultCode resultText verifyID}

    def initialize(opts = {})
      @opts = opts
      @client = SOAP::WSDLDriverFactory.new('https://secure.incab.se/axis2/services/DTServerModuleService_v1?wsdl').create_rpc_driver
    end
  end
end
