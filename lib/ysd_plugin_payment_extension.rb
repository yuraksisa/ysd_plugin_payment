# encoding: utf-8
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
        {:value => 'bank_transfer',
         :description => 'Available payment methods',
         :module => :payments})  

      SystemConfiguration::Variable.first_or_create(
        {:name => 'payments.default_currency', 
         :value => 'EUR',
         :description => 'Default payment currency',
         :module => :payments})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.pi4b.merchant_id'},
        {:value => '12345677890',
         :description => 'Pasarela Pasat Internet 4B: Código de comercio',
         :module => :payments})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.pi4b.remote_address'},
        {:value => '194.224.159.57',
         :description => 'Pasarela Pasat Internet 4B: Código de comercio',
         :module => :payments})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.pi4b.url'},
        {:value => 'https://tpv2.4b.es/simulador/teargral.exe',
         :description => 'Pasarela Pasat Internet 4B: URL conexión con la pasarela'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.paypal_standard.remote_address'},
        {:name => 'payments.paypal_standard.remote_address',
         :value => 'https://www.sandbox.paypal.com',
         :description => 'Paypal standard. Pagina paypal: https://www.sandbox.com.paypal.com or https://www.paypal.com'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.paypal_standard.url'},
        {:name => 'payments.paypal_standard.url',
         :value => 'https://www.sandbox.paypal.com',
         :description => 'Paypal standard URL form'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.paypal_standard.business_email',
         :value => 'myaccount@myserver.com',
         :description => 'Paypal business email'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.url'},
        {:value => 'http://tpv.ceca.es:8000/cgi-bin/tpv',
         :description => 'Pasarela Cecabank: URL conexión con la pasarela'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.merchant_id'},
        {:value => '123456789',
         :description => 'Pasarela Cecabank: Merchant Id'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.acquirer_id'},
        {:value => '1234567890',
         :description => 'Pasarela Cecabank: Acquirer Id'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.terminal_id'},
        {:value => '12345678',
         :description => 'Pasarela Cecabank: Terminal Id'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.clave_encriptacion'},
        {:value => '12345678',
         :description => 'Pasarela Cecabank: Clave encriptación'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.url_ok'},
        {:value => 'http://www.mydomain.com/charge-ok/cecabank',
         :description => 'Pasarela Cecabank: URL a la que dirige la pasarela si el cobro se ha realizado'})

      SystemConfiguration::SecureVariable.first_or_create(
        {:name => 'payments.cecabank.url_nok'},
        {:value => 'http://www.mydomain.com/charge-nok/cecabank',
         :description => 'Pasarela Cecabank: URL a la que dirige la pasarela si se ha producido un error'})

    end

    # --------- Menus --------------------
    
    #
    # It defines the admin menu menu items
    #
    # @return [Array]
    #  Menu definition
    #
    def menu(context={})
      
      app = context[:app]

      menu_items = [{:path => '/apps/payments',              
                     :options => {:title => app.t.system_admin_menu.apps.payments_menu.title,
                                  :description => 'Payments',
                                  :module => :payments,
                                  :weight => 1}
                    },
                    {:path => '/apps/payments/charges',              
                     :options => {:title => app.t.system_admin_menu.apps.payments_menu.charges,
                                  :link_route => "/admin/charges",
                                  :description => 'Query charges',
                                  :module => :payments,
                                  :weight => 1}
                    }
                    ]                      
    
    end  

    # ========= Routes ===================
    
    # routes
    #
    # Define the module routes, that is the url that allow to access the funcionality defined in the module
    #
    #
    def routes(context={})
    
      routes = [{:path => '/apps/payments/charges',
                 :regular_expression => /^\/admin\/charges/, 
                 :title => 'Charges', 
                 :description => 'Charges management',
                 :fit => 1,
                 :module => :payments }]
      
    end
  
    #
    # ---------- Path prefixes to be ignored ----------
    #

    #
    # Ignore the following path prefixes in language processor
    #
    def ignore_path_prefix_language(context={})
      %w(/charge /charge-return /charge-detail /charge-processed)
    end

    #
    # Ignore the following path prefix in cms
    #
    def ignore_path_prefix_cms(context={})
      %w(/charge /charge-return /charge-detail /charge-processed)
    end

  end #MailExtension
end #Social