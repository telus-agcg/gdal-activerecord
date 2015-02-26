module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter
      class TableDefinition < ActiveRecord::ConnectionAdapters::TableDefinition
        def primary_key(name, type = :primary_key, **options)
          return super unless type == :uuid
          puts "#primary_key: #{name}"

          options[:default] = options.fetch(:default, 'uuid_generate_v4()')
          options[:primary_key] = true

          column(name, type, options)
        end
      end
    end
  end
end
