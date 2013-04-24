module Sinatra
  module YSD
  	#
  	# Sinatra extension to manage charges
  	#
  	module ChargeManagement

      def self.registered(app)

        app.get '/admin/charges' do 
          load_page :charges_management, :locals => {:charges_page_size => 20}
        end

      end

  	end #ChargeManagement
  end #YSD
end #Sinatra