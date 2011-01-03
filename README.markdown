Work in progress!
----

This is **work in progress and not usable yet**. [Readme Driven Development](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html)... 

WIP docs below
----

This is a wrapper of the DebiTech SOAP API that is API compatible with the DebiTech Java client (but runs on MRI). 

Installing
----

    gem install debitech_soap

Usage
----
 
This is how you would have used the DebiTech Java API:

    # include_class "com.verifyeasy.server.VEServer"
    # veserver = VEServer.get_instance("https://secure.incab.se/verify/server/merchant_name")

This is how you use DebitechSoap:

    require 'debitech_soap'
    veserver = DebitechSoap::API.new(:shopName => "merchant_name", :userName => "api_user_name", :password => "api_user_password")

Supported arguments
----

Java style:

    veserver.refund(1234567, 23456, 100, "extra")

Hash:

    veserver.refund(:verifyID => 1234567, :transID => 23456, :amount => 100, :extra => "extra")

Custom methods
----

**valid_credentials?**: Returns **true** if the credentials work (calls "checkSwedishPersNo").

Return data
----

Return data can be accessed in a few different ways: "infoCode" can also be "getInfoCode" or "get_info_code".

Methods that have mappings for java-style method calls
----

See DebitechSoap::API::PARAMS.keys (in lib/debitech_soap.rb).

API docs
----

Get DIBSServerManual.pdf from the DIBS Manager.

Known issues
----

- Does not work with Ruby 1.9 (does not have "soap/wsdlDriver"). We have not been able to get "savon" to work.

