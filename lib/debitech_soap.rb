require 'soap/wsdlDriver'
require 'ostruct'
require 'rubygems'
require 'debitech_soap/string_extensions'

module DebitechSoap
  class API

    RETURN_DATA = %w{aCSUrl acquirerAddress acquirerAuthCode acquirerAuthResponseCode acquirerCity acquirerConsumerLimit acquirerErrorDescription acquirerFirstName acquirerLastName acquirerMerchantLimit acquirerZipCode amount errorMsg infoCode infoDescription pAReqMsg resultCode resultText verifyID}

    PARAMS = { %w(settle)                     => ["verifyID", "transID", "amount", "extra"],
               %w(subscribeAndSettle subscribe_and_settle) \
                                              => ["verifyID", "transID", "data", "ip", "extra"],
               %w(authorize)                  => ["billingFirstName", "billingLastName", "billingAddress", "billingCity",
                                                  "billingCountry", "cc", "expM", "expY", "eMail", "ip", "data", "currency", "transID", "extra"],
               %w(authorizeAndSettle3DS authorize_and_settle_3ds) \
                                              => ["verifyID", "paRes", "extra"],
               %w(refund)                     => ["verifyID", "transID", "amount", "extra"],
               %w(askIf3DSEnrolled ask_if_3ds_enrolled) \
                                              => ["billingFirstName", "billingLastName", "billingAddress", "billingCity",
                                                  "billingCountry", "cc", "expM", "expY", "eMail", "ip", "data", "currency", "transID",
                                                  "httpAcceptHeader", "httpUserAgentHeader", "method", "referenceNo", "extra"],
               %w(authReversal auth_reversal) => ["verifyID", "amount", "transID", "extra"],
               %w(authorize3DS authorize_3ds) => ["verifyID", "paRes", "extra"],
               %w(subscribe)                  => ["verifyID", "transID", "data", "ip", "extra"],
               %w(authorizeAndSettle authorize_and_settle) \
                                              => ["billingFirstName", "billingLastName", "billingAddress", "billingCity", "billingCountry",
                                                  "cc", "expM", "expY", "eMail", "ip", "data", "currency", "transID", "extra"] }

    def initialize(opts = {})
      @api_credentials = {}
      @api_credentials[:shopName] = opts[:merchant]
      @api_credentials[:userName] = opts[:username]
      @api_credentials[:password] = opts[:password]

      disable_stderr do
        @client = SOAP::WSDLDriverFactory.new('https://secure.incab.se/axis2/services/DTServerModuleService_v1?wsdl').create_rpc_driver
      end

      define_java_wrapper_methods!
    end

    def valid_credentials?
      disable_stderr do
        @client.checkSwedishPersNo(@api_credentials.merge({ :persNo => "555555-5555" })).return == "true"
      end
    end

  private

    def define_java_wrapper_methods!
      PARAMS.keys.flatten.each { |method|
        (class << self; self; end).class_eval do                          # Doc:
          define_method(method) do |*args|                                # def refund(*args)
            attributes = @api_credentials.clone

            if args.first.is_a?(Hash) 
              attributes.merge!(args.first)
            else
              parameter_order = api_signature(method).last
              args.each_with_index { |argument, i|
                attributes[parameter_order[i].to_sym] = argument
              }
            end            
            begin
              client_result = @client.send(api_signature(method).first.first, attributes)
            rescue Timeout::Error
              client_result = OpenStruct.new(:resultCode => 403, :resultText => "SOAP Timeout")
              return return_data(client_result)
            end
            return_data(client_result.return)
          end
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
          hash[attribute.underscore] = result
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

    def api_signature(method)
      PARAMS.find {|key,value| key.include?(method.to_s) }
    end

  end
end
