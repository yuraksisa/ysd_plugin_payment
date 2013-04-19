require 'ysd-plugins_viewlistener' unless defined?Plugins::ViewListener
require 'ysd_md_configuration' unless defined?SystemConfiguration::Variable
#
# Forum Extension
#
module Huasi

  class PaymentExtension < Plugins::ViewListener
                        
    # ========= Install ==================
    
    def install(context={})
    
      SystemConfiguration::Variable.first_or_create(
        {:name => 'payments.available_methods'},
        {:value => '',
         :description => 'Available payment methods',
         :module => :payments})  

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.pi4b.merchant_id',
         :value => '',
         :description => 'Pasarela Pasat Internet 4B: Código de comercio',
         :module => :payments})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.pi4b.url',
         :value => 'https://tpv2.4b.es/simulador/teargral.exe',
         :description => 'Pasarela Pasat Internet 4B: URL conexión con la pasarela'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.url',
         :value => 'http://tpv.ceca.es:8000/cgi-bin/tpv',
         :description => 'Pasarela Cecabank: URL conexión con la pasarela'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.merchant_id',
         :value => '',
         :description => 'Pasarela Cecabank: Merchant Id'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.acquirer_id',
         :value => '',
         :description => 'Pasarela Cecabank: Acquirer Id'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.acquirer_id',
         :value => '',
         :description => 'Pasarela Cecabank: Terminal Id'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.clave_encriptacion',
         :value => '',
         :description => 'Pasarela Cecabank: Clave encriptación'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.url_ok',
         :value => '',
         :description => 'Pasarela Cecabank: URL a la que dirige la pasarela si el cobro se ha realizado'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.url_nok',
         :value => '',
         :description => 'Pasarela Cecabank: URL a la que dirige la pasarela si se ha producido un error'})

    end

  
  end #MailExtension
end #Social