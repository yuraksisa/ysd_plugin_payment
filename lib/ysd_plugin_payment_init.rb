require 'ysd-plugins' unless defined?Plugins::Plugin
require 'ysd_plugin_payment_extension'

Plugins::SinatraAppPlugin.register :payment do

   name=        'payment'
   author=      'yurak sisa'
   description= 'Integrate the payment application'
   version=     '0.1'
   sinatra_extension Sinatra::YSD::Payment
   sinatra_extension Sinatra::YSD::PaymentRESTApi
   sinatra_extension Sinatra::YSD::PaymentGateway
   sinatra_extension Sinatra::YSD::PI4BPaymentGateway
   sinatra_extension Sinatra::YSD::RedsysTpvVirtualPaymentGateway
   sinatra_extension Sinatra::YSD::Redsys256TpvVirtualPaymentGateway
   sinatra_extension Sinatra::YSD::PaypalStandardPaymentGateway
   sinatra_extension Sinatra::YSD::ChargeManagement
   sinatra_extension Sinatra::YSD::ChargeManagementRESTApi
   hooker            Huasi::PaymentExtension
  
end