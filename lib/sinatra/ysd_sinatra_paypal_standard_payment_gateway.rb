require 'ysd_md_configuration' unless defined?SystemConfiguration::SecureVariable

module Sinatra
  module YSD
    #
    # This module manages the communication to the Paypal payment gateway
    #
    # Paypal Standard continues to the url /charge-return/paypal-standard when the payment has been done
    # Paypal Standard continues to the url /charge-return/paypal-standard/cancel if the user backs to the origin
    #
    module PaypalStandardPaymentGateway

      def self.registered(app)

        #
        # Paypal return cancel 
        #          
        app.get '/charge-return/paypal-standard/cancel',
          :allowed_origin => lambda {SystemConfiguration::SecureVariable.get_value('payments.paypal_standard.remote_address')} do
            
            charge_id = session[:charge_id]

            if charge = Payments::Charge.get(charge_id)
              
              if charge_source = charge.charge_source
                method_name = "#{charge_source.class.name.split('::').last.downcase}_gateway_return_cancel".to_sym
                if settings.respond_to?(method_name) 
                  redirect_url = settings.send(method_name) 
                  status, header, body = call! env.merge("PATH_INFO" => redirect_url, 
                     "REQUEST_METHOD" => 'GET') 
                else
                  status 200
                  body "No #{method_name}" #TODO CHANGE
                end
              else
                status 200
                body "Charge without source" #TODO CHANGE
              end
           
            else
              status 404
            end

        end

        #
        # Paypal return
        #         
        app.post '/charge-return/paypal-standard',
          :allowed_origin => lambda {SystemConfiguration::SecureVariable.get_value('payments.paypal_standard.remote_address')} do
          
            charge_id = params[:invoice]
            session[:charge_id] = charge_id

            if charge = Payments::Charge.get(charge_id)

              if charge_source = charge.charge_source
                method_name = "#{charge_source.class.name.split('::').last.downcase}_gateway_return_ok".to_sym
                if settings.respond_to?(method_name)
                  redirect_url = settings.send(method_name) 
                  status, header, body = call! env.merge("PATH_INFO" => redirect_url, 
                     "REQUEST_METHOD" => 'GET') 
                else
                  status 200
                  body "No #{method_name}" #TODO CHANGE
                end
              else
                status 200
                body "Charge without source" #TODO CHANGE
              end
            
            else
              status 404
            end

        end

        #
        # Paypal notification
        # 
        app.post '/charge-processed/paypal-standard' do
  #        :allowed_remote => lambda {SystemConfiguration::SecureVariable.get_value('payments.paypal_standard.remote_address')} do

           response = validate_IPN_notification(request.raw_post)
           
           case response
                when "VERIFIED"
                   charge_id = params[:invoice]
                   p "CONFIRMATION : #{charge_id}"
                   if charge = Payments::Charge.get(charge_id)
                     charge.update(:status => :done) 
                   end
                when "INVALID"
                   # log for investigation
                   logger.error "Paypal IPN INVALID"
                else
                   # error
           end

        end

      end

      def validate_IPN_notification(raw)
         uri = URI.parse('https://www.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
         http = Net::HTTP.new(uri.host, uri.port)
         http.open_timeout = 60
         http.read_timeout = 60
         http.verify_mode = OpenSSL::SSL::VERIFY_NONE
         http.use_ssl = true
         response = http.post(uri.request_uri, raw,
                         'Content-Length' => "#{raw.size}",
                         'User-Agent' => "My custom user agent"
                       ).body
      end     

    end
  end
end