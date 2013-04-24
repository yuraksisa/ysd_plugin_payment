require 'spec_helper'
require 'rack/test'
require 'ysd_md_configuration' unless defined?SystemConfiguration::Variable
require 'json'

describe Sinatra::YSD::ChargeManagementRESTApi do
  include Rack::Test::Methods

  let(:charge) do
  	 {:date => Time.new(2013,5,10),
      :amount => 150,
      :payment_method_id => :pi4b,
      :currency => :EUR}
  end
  
  def app
    TestingSinatraApp.class_eval do
      register Sinatra::YSD::ChargeManagementRESTApi
    end
    TestingSinatraApp
  end

  describe "POST /charges" do
    
    before :each do
      SystemConfiguration::Variable.should_receive(:get_value).
          with('configuration.charge_page_size', 20).
          and_return(10) 
    end

    context "no pagination and no query" do

      before :each do
        Payments::Charge.should_receive(:all_and_count).
          with(hash_including({:offset => 0, :limit => 10})).
          any_number_of_times.
          and_return([[Payments::Charge.new(charge)], 1])
      end

      subject do
        post '/charges', {}
        last_response
      end

      its(:status) { should == 200 } 
      its(:header) { should have_key 'Content-Type' }
      it { subject.header['Content-Type'].should match(/application\/json/) }
      its(:body) { should == {:data => [Payments::Charge.new(charge)], :summary => {:total => 1}}.to_json }
    
    end

    context "pagination" do

      before :each do
        Payments::Charge.should_receive(:all_and_count).
          with(hash_including({:offset => 10, :limit => 10})).
          any_number_of_times.
          and_return([[Payments::Charge.new(charge)], 1])
      end

      subject do
        post '/charges/page/2', {}
        last_response
      end

      its(:status) { should == 200 } 
      its(:header) { should have_key 'Content-Type' }
      it { subject.header['Content-Type'].should match(/application\/json/) }
      its(:body) { should == {:data => [Payments::Charge.new(charge)], :summary => {:total => 1}}.to_json }

    end

    context "pagination and query" do

      before :each do
        Payments::Charge.should_receive(:all_and_count).
          with(hash_including(:offset => 10, :limit => 10)).
          any_number_of_times.
          and_return([[Payments::Charge.new(charge)], 1])
      end

      subject do 
        post '/charges/page/2', {:search => '150'}
        last_response
      end
      
      its(:status) {should == 200}
      its(:header) {should have_key 'Content-Type'}
      it { subject.header['Content-Type'].should match(/application\/json/) }
      its(:body) { should == {:data => [Payments::Charge.new(charge)], :summary => {:total => 1}}.to_json }

    end



  end


end