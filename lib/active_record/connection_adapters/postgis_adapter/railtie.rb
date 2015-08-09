require 'rails/railtie'
require 'active_record/connection_adapters/postgis_adapter'

module ActiveRecord
  module ConnectionAdapters
    module PostGISAdapter
      class Railtie < ::Rails::Railtie
        load 'active_record/railties/databases.rake'
      end
    end
  end
end
