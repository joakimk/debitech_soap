require 'soap/wsdlDriver'
require 'ostruct'
require 'rubygems'
require 'active_support'

begin
  # Required for active_support 3+
  require 'active_support/core_ext/string/inflections'
rescue LoadError
end

module DebitechSoap
  class API

    RETURN_DATA = %w{aCSUrl acquirerAddress acquirerAuthCode acquirerAuthResponseCode acquirerCity acquirerConsumerLimit acquirerErrorDescription acquirerFirstName acquirerLastName acquirerMerchantLimit acquirerZipCode amount errorMsg infoCode infoDescription pAReqMsg resultCode resultText verifyID}

    PARAMS = { "settle"                => ["verifyID", "transID", "amount", "extra"],
               "subscribe_and_settle"  => ["verifyID", "transID", "data", "ip", "extra"],
               "authorize"             => ["billingFirstName", "billingLastName", "billingAddress", "billingCity",
                                           "billingCountry", "cc", "expM", "expY", "eMail", "ip", "data", "currency", "transID", "extra"],
               "authorizeAndSettle3DS" => ["verifyID", "paRes", "extra"],
               "refund"                => ["verifyID", "transID", "amount", "extra"],
               "askIf3DSEnrolled"      => ["billingFirstName", "billingLastName", "billingAddress", "billingCity",
                                           "billingCountry", "cc", "expM", "expY", "eMail", "ip", "data", "currency", "transID",
                                           "httpAcceptHeader", "httpUserAgentHeader", "method", "referenceNo", "extra"],
               "auth_reversal"         => ["verifyID", "amount", "transID", "extra"],
               "authorize3DS"          => ["verifyID", "paRes", "extra"],
               "subscribe"             => ["verifyID", "transID", "data", "ip", "extra"],
               "authorize_and_settle"  => ["billingFirstName", "billingLastName", "billingAddress", "billingCity", "billingCountry",
                                           "cc", "expM", "expY", "eMail", "ip", "data", "currency", "transID", "extra"] }

    def initialize(opts = {})
      @api_credentials = opts
      
      disable_stderr do
        @client = SOAP::WSDLDriverFactory.new('https://secure.incab.se/axis2/services/DTServerModuleService_v1?wsdl').create_rpc_driver
      end

      define_jruby_wrapper_methods!  
    end

    def valid_credentials?
      disable_stderr do
        @client.checkSwedishPersNo(@api_credentials.merge({ :persNo => "555555-5555" })).return == "true"
      end
    end

  private

    def define_jruby_wrapper_methods!
      PARAMS.keys.each { |method|
        (class << self; self; end).class_eval do                          # Doc:
          define_method(method) do |*args|                                # def refund(*args)
            attributes = @api_credentials

            if args.first.is_a?(Hash) 
              attributes.merge!(args.first)
            else
              parameter_order = PARAMS[method.to_s] 
              args.each_with_index { |argument, i|
                attributes[parameter_order[i].to_sym] = argument
              }
            end

            return_data @client.send(method, attributes).return
          end                                                             # end
        end
      }
    end

    def return_data(results)
      hash = {}
      
      RETURN_DATA.each { |attribute|
        result = results.send(attribute)
        unless result.is_a?(SOAP::Mapping::Object)
          result = result.to_i if integer?(result)
          hash[attribute] = result
          hash["get_" + attribute.underscore] = result
          hash["get" + attribute.camelcase] = result
        end
      }
      
      OpenStruct.new(hash)
    end

    def integer?(result)
      result.to_i != 0 || result == "0"
    end

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
