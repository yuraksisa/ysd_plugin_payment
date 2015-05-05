require 'ysd_md_configuration' unless defined?SystemConfiguration::SecureVariable

module Sinatra
  module YSD
    #
    # This module manages the communication to Redsys payment gateway
    #
    # Redsys continues to the url /charge-return/redsys when the payment has been done
    # Redsys continues to the url /charge-return/redsys/cancel if the user backs to the origin
    #
    module RedsysTpvVirtualPaymentGateway

      def self.registered(app)

        #
        # Return
        #         
        app.get '/charge-return/redsys' do
            
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
        app.post '/charge-processed/redsys' do
 
          p "charge-processed"

          charge_id = params[:Ds_Order].to_i
          result = params[:Ds_Response]
          signature = params[:Ds_Signature]

          payment_method = Payments::PaymentMethod.get(:redsys)
          calculated_signature = payment_method.calculate_response_signature(
                                  params[:Ds_Order],
                                  params[:Ds_Amount], 
                                  params[:Ds_Response],
                                  params[:Ds_Currency],
                                  params[:Ds_MerchantCode])
          
          if signature != calculated_signature
            p "Calculated signature does not match #{signature} ** #{calculated_signature}"
            status 404
          else
            if charge = Payments::Charge.get(charge_id)
              case result
                when "0000".."0099"
                  charge.update(:status => :done)
                else
                  charge.update(:status => :denied)
              end
              status 200
            else
              status 404
            end
          end
        end

        #
        # Return cancel 
        #          
        app.get '/charge-return/redsys/cancel' do
            
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