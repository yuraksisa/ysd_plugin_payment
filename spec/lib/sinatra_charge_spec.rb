require 'spec_helper'
require 'rack/test'
require 'sinatra/ysd_sinatra_charge'
require 'ysd_md_payment'

describe Sinatra::YSD::Charge do
  include Rack::Test::Methods

  def app
    TestingSinatraApp.register Sinatra::YSD::Charge
    TestingSinatraApp
  end

  context "when a gateway payment charge in session" do
    
    before do
      charge = Payments::Charge.create({:payment_method_id => :cecabank, 
      	  :amount => 100,
      	  :currency => 'EUR'})	
      Payments::Charge.should_receive(:get).with(1).and_return(charge)
    end

    subject do 
      get '/charge', {}, {'rack.session' => {'charge_id' => 1 }} 
      last_response
    end

    it { should be_ok }
    its(:header) { should have_key 'Content-Type' }
    it { subject.header['Content-Type'].should match(/text\/html/) }
    its(:body) { should match(/method="POST"/)}

  end

  context "when no charge in session" do

    subject do 
      get '/charge' 
      last_response
    end   

    its(:status) { should == 404 }

  end

end