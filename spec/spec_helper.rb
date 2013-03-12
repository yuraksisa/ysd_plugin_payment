require 'ysd_md_payment'
require 'ysd_plugin_payment'
require 'sinatra/base'
require 'sinatra/r18n'

class TestingSinatraApp < Sinatra::Base
  register Sinatra::R18n
end

module DataMapper
  class Transaction
  	module SqliteAdapter
      def supports_savepoints?
        true
      end
  	end
  end
end

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup :default, "sqlite3::memory:"
DataMapper::Model.raise_on_save_failure = false
DataMapper.finalize 

DataMapper.auto_migrate!
