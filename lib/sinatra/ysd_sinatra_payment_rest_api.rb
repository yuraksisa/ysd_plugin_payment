require 'ysd_md_payment' unless defined?Payments::PaymentMethod

module Sinatra
  module YSD
    #
    # Payment Sinatra REST API
    #
    module PaymentRESTApi
   
      def self.registered(app)
                            
        #
        # Retrive available payment methods (GET)
        #
        app.get "/paymethods" do
          content_type :json
          Payments::PaymentMethod.available.to_json
        end
        
        #
        # Retrieve online/gateway available payment methods (GET)
        # 
        app.get "/paymethods/online" do
          payment_methods = Payments::PaymentMethod.available.select do |item|
            item.is_a?(Payments::GatewayPaymentMethod)
          end
          content_type :json
          payment_methods.to_json
        end

      end
    
    end #ForumManagement
  end #YSD
end #Sinatra