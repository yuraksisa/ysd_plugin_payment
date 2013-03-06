require 'ysd-plugins' unless defined?Plugins::Plugin
require 'ysd_plugin_payment_extension'

Plugins::SinatraAppPlugin.register :forum do

   name=        'forum'
   author=      'yurak sisa'
   description= 'Integrate the forum application'
   version=     '0.1'
   sinatra_extension Sinatra::YSD::Payment
   sinatra_extension Sinatra::YSD::PaymentRESTApi
   hooker            Huasi::PaymentExtension
  
end