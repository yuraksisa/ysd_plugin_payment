require 'ysd_md_configuration' unless defined?SystemConfiguration::SecureVariable

module Sinatra
  module YSD
    #
    # This module manages the communication to Redsys payment gateway
    #
    # Redsys continues to the url /charge-return/redsys256 when the payment has been done
    # Redsys continues to the url /charge-return/redsys256/cancel if the user backs to the origin
    #
    module Redsys256TpvVirtualPaymentGateway

      def self.registered(app)

        #
        # Return
        #         
        app.get '/charge-return/redsys256' do
            
            p "charge-return charge_id : #{session[:charge_id]}"

            charge_id = session[:charge_id]

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
        # Payment notification
        # 
        app.post '/charge-processed/redsys256' do
 
          p "charge-processed"

          payment_method = Payments::PaymentMethod.get(:redsys256)
          
          signature = Base64.strict_encode64(Base64.urlsafe_decode64(params[:Ds_Signature]))
          ds_merchant_parameters = params[:Ds_MerchantParameters]
          ds_merchant_parameters_decoded = payment_method.decode_merchant_parameters(ds_merchant_parameters)
          charge_id = ds_merchant_parameters_decoded['Ds_Order'].to_i
          result = ds_merchant_parameters_decoded['Ds_Response']
          
          if charge = Payments::Charge.get(charge_id)
            case result
              when "0000".."0099"
                calculated_signature = payment_method.firma(ds_merchant_parameters, charge_id)
                if signature == calculated_signature
                  charge.update(:status => :done)
                  status 200
                else
                  p "Calculated signature does not match #{signature} ** #{calculated_signature}"
                  status 404                 
                end
              else
                p "Payment error #{result}"
                charge.update(:status => :denied)
                status 200
            end
          else
            status 404
          end

        end

        #
        # Return cancel 
        #          
        app.get '/charge-return/redsys256/cancel' do
            
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

      end

    end
  end
end