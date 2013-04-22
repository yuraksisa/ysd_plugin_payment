module Sinatra
  module YSD
    #
    # This module manages the communication to the PI4B payment gateway
    #
    # PI4B request for charge detail to /charge-detail/pi4b
    # 
    # PI4B notifies that it has processed the charge to /charge-ok/pi4b
    # PI4B notifies an error on the process to /charge-nok/pi4b
    #
    #
    module PI4BPaymentGateway

      def self.registered(app)

        #
        # PI4B payment gateway requests for charge detail 
        #
        app.get '/charge-detail/pi4b' do

          if pi4b = Payments::PaymentMethod.get(:pi4b)
            if charge_detail = pi4b.charge_detail(
               :merchant_id => params[:store],
               :charge_id => params[:order])
              status 200
              body= charge_detail 
            else
              status 404
            end
          else
            status 404
          end

        end
        
        #
        # PI4B return page
        #
        app.get '/charge-return/pi4b' do
        
          charge_id = params[:pszPurchorderNum]  
          result = params[:result]
          
          #
          # ATTENTION result 0 (ok) 2 (denied)
          #
          if result == "0" 

          	if charge = Payments::Charge.get(charge_id)
              method_name = "#{charge_source.class.name}_gateway_return_ok".to_sym
              if charge_source = charge.charge_source
                redirect_url = settings.send(method_name) if settings.respond_to?(method_name)
              end

              status, header, body = call! env.merge("PATH_INFO" => redirect_url, 
                 "REQUEST_METHOD" => 'GET') 

          else

          end

        end
        
        #
        # PI4B payment gateway confirm the charge
        #
        app.get '/charge-processed/pi4b' do

          merchant_id = params[:store]
          charge_id = params[:pszPurchorderNum]
          result = params[:result]
          
          puts "PROCESSING charge : #{charge_id} RESULT : #{result}"

          if charge = Payments::Charge.get(charge_id)
          	case result
          	  when "0"
                charge.status = :done
              when "2"
              	charge.status = :denied
              else
              	puts "Result is not 0 or 2"
            end
            charge.save
            status 200
          else
            status 404
          end

        end
      
      end

    end
  end
end