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
        
      end
    
    end #ForumManagement
  end #YSD
end #Sinatra