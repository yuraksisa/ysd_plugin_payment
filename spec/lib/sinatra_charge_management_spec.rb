require 'spec_helper'
require 'rack/test'
require 'sinatra/ysd_sinatra_charge_management'

describe Sinatra::YSD::ChargeManagement do 
  include Rack::Test::Methods
  include ThemeMock

  def app
    TestingSinatraApp.class_eval do
      register Sinatra::YSD::ChargeManagement
    end
    TestingSinatraApp
  end

  describe '/admin/charges' do
   
   before :each do
     init_theme
   end
   
   subject do 
     get '/admin/charges'
     last_response       
   end
 
   its(:status) { should == 200 }
   its(:header) { should have_key 'Content-Type' }
   it { subject.header['Content-Type'].should match(/text\/html/) }
   its(:body) { should match /ChargeHook/ }
 
  end	

end