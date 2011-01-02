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

Custom methods
----

Returns true if the credentials work (calls "checkSwedishPersNo").

    veserver.valid_credentials?

API
----

See the java client docs in the DIBSServerManual.pdf available from the DIBS Manager.

