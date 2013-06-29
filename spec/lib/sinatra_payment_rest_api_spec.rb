require 'spec_helper'
require 'rack/test'
require 'ysd_md_configuration'
require 'json'

describe Sinatra::YSD::PaymentRESTApi do
  include Rack::Test::Methods

  def app  
    TestingSinatraApp.register Sinatra::YSD::PaymentRESTApi

    TestingSinatraApp
  end
  
  context "retrieving available payment methods" do

    before do 
      SystemConfiguration::Variable.should_receive(:get_value)
        .with('payments.available_methods').and_return('cecabank')
    end

    subject do 
      get "/paymethods"
      JSON.parse(last_response.body)
    end

    it { should be_a_kind_of Array }   
    its(:first) { should be_a_kind_of Hash }
    its(:first) { should have_key('id') }
    its(:first) { should have_key('title') }
    its(:first) { should have_key('description') }

  end

  context "retrieving available online payment methods" do

    before do
      SystemConfiguration::Variable.should_receive(:get_value)
        .with('payments.available_methods').and_return('cecabank,bank_transfer')
    end

    subject do 
      get "/paymethods/online"
      JSON.parse(last_response.body)
    end

    it { should be_a_kind_of Array}
    its (:first) { should be_a_kind_of Hash }
    its (:length) { should == 1 }

  end

end