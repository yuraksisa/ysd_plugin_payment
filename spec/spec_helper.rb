require 'ysd_md_payment'
require 'ysd_plugin_payment'
require 'sinatra/base'
require 'sinatra/r18n'

class TestingSinatraApp < Sinatra::Base
  register Sinatra::R18n
  register Sinatra::YSD::Payment
  register Sinatra::YSD::PaymentRESTApi
end
