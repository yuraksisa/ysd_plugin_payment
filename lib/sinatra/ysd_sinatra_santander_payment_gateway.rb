require 'ysd_md_configuration' unless defined?SystemConfiguration::SecureVariable

module Sinatra
  module YSD
    #
    # This module manages the communication to the Santander Avalon payment gateway
    #
    # Santander Elavon TPV continues to the url /charge-return/santander when the payment has been done
    # From the resturn URL respond with a form to follow the process
    #
    module SantanderPaymentGateway

      def self.registered(app)

        #
        # Santander Elavon TPV platform responds to this URL
        #
        app.post '/charge-return/santander' do 

          site_domain = SystemConfiguration::Variable.get_value("site.domain")
          url = "#{site_domain}/charge-return/santander-return"

          # Hold the parameters received in the POST
          result = params[:RESULT]
          message = params[:MESSAGE]
          pasref = params[:PASREF]
          authcode = params[:AUTHCODE]
          merchant_code = params[:MERCHANT_ID]
          account = params[:ACCOUNT]
          charge_id = params[:ORDER_ID]
          timestamp = params[:TIMESTAMP]
          amount = params[:AMOUNT]
          sha1hash = params[:SHA1HASH]

          # Process the notification
         
          if charge = Payments::Charge.get(charge_id.to_i)
            if result == "00" # Operation successful
              payment_method = Payments::PaymentMethod.get(:santander)
              calculated_signature = payment_method.return_signature(timestamp,
                                       merchant_code, charge_id, 
                                       result, message, pasref, authcode)
              if calculated_signature == sha1hash
                charge.update(:status => :done)
              else
                logger.error "santander signature #{sha1hash} does not match calculated signature #{calculated_signature}"
              end
            else
              charge.update(:status => :denied)
            end
          else
            logger.error("charge #{charge_id} not found")
          end

          # Prepare the response
          response = <<-EOF
            <form name="responseform" target="_parent" action="#{url}" method="POST">
              <input type=hidden name="MERCHANT_ID" value="#{merchant_code}">
              <input type=hidden name="ORDER_ID" value="#{charge_id}">
              <input type=hidden name="ACCOUNT" value="#{account}">
              <input type=hidden name="AMOUNT" value="#{amount}">
              <input type=hidden name="TIMESTAMP" value="#{timestamp}">
              <input type=hidden name="SHA1HASH" value="#{sha1hash}">
              <input type=hidden name="RESULT" value="#{result}">
              <input type=hidden name="MESSAGE" value="#{message}">
              <input type=hidden name="PASREF" value="#{pasref}">
              <input type=hidden name="AUTHCODE" value="#{authcode}">
            </form>
            <script> document.responseform.submit(); </script>
          EOF

          status 200
          response

        end

        #
        # The URL that we respond
        #
        app.post '/charge-return/santander-return' do

          result = params[:RESULT]
          message = params[:MESSAGE]
          pasref = params[:PASREF]
          authcode = params[:AUTHCODE]
          merchant_code = params[:MERCHANT_ID]
          account = params[:ACCOUNT]
          charge_id = params[:ORDER_ID]
          timestamp = params[:TIMESTAMP]
          amount = params[:AMOUNT]
          sha1hash = params[:SHA1HASH]

          if charge = Payments::Charge.get(charge_id.to_i)
            if charge_source = charge.charge_source
              payment_method = Payments::PaymentMethod.get(:santander)
              calculated_signature = payment_method.return_signature(timestamp,
                                       merchant_code, charge_id, 
                                       result, message, pasref, authcode)
              if calculated_signature == sha1hash
                method_name = "#{charge_source.class.name.split('::').last.downcase}_gateway_return_ok".to_sym
                if settings.respond_to?(method_name)
                  redirect_url = settings.send(method_name) 
                  status, header, body = call! env.merge("PATH_INFO" => redirect_url, 
                     "REQUEST_METHOD" => 'GET') 
                else
                  logger.error "#{method_name} not found on settings"
                  status 404
                end
              else
                logger.error "santander signature #{sha1hash} does not match calculated signature #{calculated_signature}"
                status 404
              end
            else
              logger.error "charge without source #{charge_id}"
              status 404
            end            
          else
          	logger.error "charge not found #{charge_id}"
            status 404
          end


        end

      end

    end
  end
end