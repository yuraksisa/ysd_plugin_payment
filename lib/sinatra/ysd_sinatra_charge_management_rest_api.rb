require 'ysd_md_configuration' unless defined?SystemConfiguration::Variable
require 'ysd_md_payment' unless defined?Payments::Charge
module Sinatra
  module YSD
  	module ChargeManagementRESTApi
      
      def self.registered(app)
        
        #
        # Retrieve charges
        #
        ["/charges", "/charges/page/:page"].each do |path|
          app.post path do
        	
            query_options = {}
            if request.media_type == "application/x-www-form-urlencoded"
              if params[:search]
                query_options[:conditions] = {:amount => "%#{params[:search]}%"} 
              else
                request.body.rewind
                search_text=request.body.read
                query_options[:conditions] = {:amount => "%#{search_text}%"} 
              end
            end
            page_size = SystemConfiguration::Variable.
              get_value('configuration.charge_page_size', 20).to_i 
            page = [params[:page].to_i, 1].max  
            data, total = Payments::Charge.all_and_count(
              query_options.merge({:offset => (page - 1)  * page_size, :limit => page_size, :order => [:date.desc]}) )
            content_type :json
            {:data => data, :summary => {:total => total}}.to_json

          end
        end

      end

    end #ChargeManagementRESTApi
  end #YSD
end #Sinatra