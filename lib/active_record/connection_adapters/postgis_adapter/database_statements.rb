require 'active_record/connection_adapters/postgresql/database_statements'

module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter
      module DatabaseStatements
        include ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::DatabaseStatements

        # Executes SQL and returns the resulting Layer.
        #
        # @param [String] sql
        # @return [OGR::Layer]
        def execute(sql, name = nil)
          log(sql, name) do
            # layer = @connection.execute_sql(sql)
            #
            # feature = layer.next_feature
            #
            # result = []
            #
            # until feature.nil?
            #   result << feature.fields.map do |field|
            #     field[:value_as_string]
            #   end
            #
            #   feature = layer.next_feature
            # end
            #
            # result
            @connection.execute_sql(sql)
          end
        end

        # @param [String] sql
        # @return [ActiveRecord::Result]
        def exec_query(sql, name = 'SQL', binds = [])
          layer = if without_prepared_statement?(binds)
            exec_no_cache(sql, name, binds)
          else
            exec_cache(sql, name, binds)
          end

          rows = extract_rows(layer)
          puts "rows: #{rows}"
          columns = extract_column_names(layer)
          puts "columns: #{columns}"
          types = extract_column_types(layer)
          puts "types: #{types}"
          @connection.release_result_set(layer)

          ActiveRecord::Result.new(columns, rows, types)
        end

        private

        def extract_column_names(layer)
          layer.feature_definition.field_definitions.map(&:name)
        end

        def extract_column_types(layer)
          layer.feature_definition.field_definitions.map(&:type)
        end

        # @param [OGR::Layer] layer
        # @return [Array<String>] Data needed to build a ActiveRecord::Result.
        def extract_rows(layer)
          rows = []
          layer.reset_reading
          feature = layer.next_feature

          until feature.nil?
            rows << feature.fields.map do |field|
              field[:value_as_string]
            end

            feature = layer.next_feature
          end

          rows
        end
      end
    end
  end
end
