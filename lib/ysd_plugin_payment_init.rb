require 'ysd-plugins' unless defined?Plugins::Plugin
require 'ysd_plugin_payment_extension'

Plugins::SinatraAppPlugin.register :forum do

   name=        'forum'
   author=      'yurak sisa'
   description= 'Integrate the payment application'
   version=     '0.1'
   sinatra_extension Sinatra::YSD::Payment
   sinatra_extension Sinatra::YSD::PaymentRESTApi
   sinatra_extension Sinatra::YSD::PaymentGateway
   sinatra_extension Sinatra::YSD::PI4BPaymentGateway
   hooker            Huasi::PaymentExtension
  
end