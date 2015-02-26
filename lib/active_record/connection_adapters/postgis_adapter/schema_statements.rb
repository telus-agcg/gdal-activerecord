require 'active_record/connection_adapters/postgresql/schema_statements'

module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter
      module SchemaStatements
        include ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::SchemaStatements

        def tables(_table_type = nil)
          puts "layer names: #{@connection.layers.map(&:name)}"
          @connection.layers.map(&:name)
        end

        # Returns true if table exists.
        # If the schema is not specified as part of +name+ then it will only find tables within
        # the current schema search path (regardless of permissions to access tables in other schemas)
        def table_exists?(table_name)
          return false if table_name.blank?

          puts "table_name: #{table_name}"

          !!@connection.layer_by_name(table_name)
        end

        def column_definitions(table_name)
          layer = @connection.layer_by_name(table_name)
          return [] unless layer

          layer.feature_definition.field_definitions
        end

        def columns(table_name, _name = nil)
          return [] if table_name.blank?

          column_definitions(table_name)
        end
      end
    end
  end
end
