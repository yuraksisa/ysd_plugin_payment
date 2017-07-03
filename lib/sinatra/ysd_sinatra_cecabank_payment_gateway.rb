require 'ysd_md_configuration' unless defined?SystemConfiguration::SecureVariable

module Sinatra
  module YSD
    #
    # This module manages the communication to Cecabank payment gateway
    #
    # Cecabank continues to the url /charge-return/cecabank when the payment has been done
    # Cecabank continues to the url /charge-return/cecabank/cancel if the user backs to the origin
    #
    module CecabankTpvVirtualPaymentGateway

      def self.registered(app)

        #
        # Return OK
        #         
        app.get '/charge-return/cecabank' do

            p "cecabank return OK charge_id : #{session[:charge_id]}"

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
        # Return cancel 
        #          
        app.get '/charge-return/cecabank/cancel' do

            p "cecabank return Cancel charge_id : #{session[:charge_id]}"

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

        # ----------------------------------------------------------------------------------

        #
        # Payment notification
        # 
        app.post '/charge-processed/cecabank' do
        
          merchant_id = params[:MerchantID]
          acquirer_bin = params[:AcquirerBIN]
          terminal_id = params[:TerminalID]
          num_operacion = params[:Num_operacion]
          importe = params[:Importe]
          tipo_moneda = params[:TipoMoneda]
          exponente = params[:Exponente]
          referencia = params[:Referencia]
          firma = params[:Firma]
          codigo_pedido = params[:Codigo_pedido]
          codigo_cliente = params[:Codigo_cliente]
          codigo_comercio = params[:Codigo_comercio]
          num_aut = params[:Num_aut]
          bin = params[:BIN]
          final_pan = params[:FinalPAN]
          cambio_moneda = params[:Cambio_moneda]
          idioma = params[:Idioma]
          pais = params[:Pais]
          tipo_tarjeta = params[:Tipo_tarjeta]
          descripcion = params[:Descripcion]

          logger.info "CECABANK Notification. Charge = #{num_operacion} -- #{merchant_id} #{acquirer_bin} #{terminal_id} #{num_operacion} #{importe} #{tipo_moneda} #{exponente} #{referencia} ** #{firma}"

          payment_method = Payments::PaymentMethod.get(:cecabank)

          # Check that the num_operation matches a charge and that the importe is the same
          if charge = Payments::Charge.get(num_operacion.to_i)
            # Check the firma
            calculated_signature = payment_method.notification_signature(merchant_id, 
            	                                                           acquirer_bin,
            	                                                           terminal_id,
            	                                                           num_operacion,
            	                                                           importe,
            	                                                           tipo_moneda,
            	                                                           exponente,
                                                                         referencia)
            if firma == calculated_signature
              charge.update(:status => :done)
              status 200
            else
              logger.error "CECABANK : Calculated signature does not match #{firma} ** #{calculated_signature}"
              status 404                 
            end
          else
          	logger.error "CECABANK : Charge not found #{num_operacion}"
            status 404	
          end  
         
        end

      end

    end
  end
end    	