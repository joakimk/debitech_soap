[![Build Status](https://secure.travis-ci.org/joakimk/debitech_soap.png)](http://travis-ci.org/joakimk/debitech_soap)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/joakimk/debitech_soap)

This is a wrapper of the DebiTech SOAP API. It's intended to be API compatible with the DebiTech Java client but also supports a more developer friendly syntax :).

If you're looking for a more complete solution, check the [debitech](https://github.com/barsoom/debitech) gem which uses this library for API access.

Installing
----

    gem install debitech_soap

Usage
----
 
This is how you would have used the DebiTech Java API:

    include_class "com.verifyeasy.server.VEServer"
    veserver = VEServer.get_instance("https://secure.incab.se/verify/server/merchant_name")

This is how you use DebitechSoap:

    require 'debitech_soap'
    veserver = DebitechSoap::API.new(:merchant => "merchant_name", :username => "api_user_name", :password => "api_user_password")

Supported arguments
----

Java style (see DebitechSoap::API::PARAMS.keys in lib/debitech_soap.rb):

    veserver.refund(1234567, 23456, 100, "extra")

Hash:

    veserver.refund(:verifyID => 1234567, :transID => 23456, :amount => 100, :extra => "extra")

Custom methods
----

**valid_credentials?**: Returns **true** if the credentials work (calls "checkSwedishPersNo").

Return data
----

- An object with methods for each attribute (See DebitechSoap::RETURN_DATA).
- Each attribute has serveral methods, for example "infoCode" can also be "getInfoCode" or "get_info_code".
- If the return value is a number it will be converted to an integer.

Gotchas
----

- We have only used the following methods in production: askIf3DSEnrolled, authorize3DS, authorize, subscribeAndSettle, checkSwedishPersNo, authorizeAndSettle.
- The other methods should work, but have not been tested.

API docs
----

Get DIBSServerManual.pdf from the DIBS Manager.

Changing HTTPClient SSL ciphers
----

If you're a library developer, you may want to experiment with changing the set of HTTPClient SSL ciphers, e.g. if DIBS deprecates old ones.

You can do that by setting an environment variable:

    DIBS_HTTPCLIENT_CIPHERS="ALL:!aNULL:!eNULL:!SSLv2"

If nothing is set, it uses the default (`HTTPClient::SSLConfig::CIPHERS_DEFAULT`).

Once the experiments are concluded, you should move that configuration into the library instead, so each user of this library doesn't have to configure it.
