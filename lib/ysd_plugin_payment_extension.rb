require 'ysd-plugins_viewlistener' unless defined?Plugins::ViewListener
require 'ysd_md_configuration' unless defined?SystemConfiguration::Variable
#
# Forum Extension
#
module Huasi

  class PaymentExtension < Plugins::ViewListener
                        
    # ========= Install ==================
    
    def install(context={})
    
      SystemConfiguration::Variable.first_or_create(
        {:name => 'payments.available_methods'},
        {:value => '',
         :description => 'Available payment methods',
         :module => :payments})  

    end

  
  end #MailExtension
end #Social