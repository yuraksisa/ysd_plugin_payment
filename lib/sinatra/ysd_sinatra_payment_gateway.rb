require 'ysd_md_payment' unless defined?Payments::Charge

module Sinatra
  module YSD
    #
    # It manages the payment gateway communication
    #
  	module PaymentGateway

      def self.registered(app)

        #
        # Connect to the payment gateway to perform the charge
        #
        # It uses the charge_id session variable to get the charge_id
        #
        app.get '/charge' do

          unless session['charge_id'] 
            halt 404
          end

          unless charge = Payments::Charge.get(session['charge_id'])
          	halt 404
          end

          unless charge.payment_method.respond_to?(:charge_form)
          	halt 404
          end
          
          form = charge.payment_method.charge_form(charge)

          status 200
          content_type :html
          body form

        end

      end

  	end #Charge
  end #YSD
end #Sinatra