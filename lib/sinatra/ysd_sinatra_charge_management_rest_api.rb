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
            if request.media_type == "application/json"
              request.body.rewind
              search_request = JSON.parse(URI.unescape(request.body.read))
              if search_request.has_key?('search') and !search_request['search'].empty?
                query_options[:conditions] = {:amount => "%#{search_request['search']}%"}
              end
            end
            page_size = 20
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