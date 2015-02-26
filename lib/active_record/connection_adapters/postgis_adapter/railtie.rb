require 'rails/railtie'
require 'active_record/connection_adapters/postgis_adapter'

module ActiveRecord
  module ConnectionAdapters
    module PostGISAdapter
      class Railtie < ::Rails::Railtie

      end
    end
  end
end
