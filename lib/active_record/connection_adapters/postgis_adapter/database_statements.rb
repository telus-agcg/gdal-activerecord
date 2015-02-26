require 'active_record/connection_adapters/postgresql_adapter/database_statements'

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
      end
    end
  end
end
