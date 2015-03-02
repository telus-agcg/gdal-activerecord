module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter
      module SchemaStatements

        # Names of tables in the current DB.
        #
        # @return [Array<String>]
        def tables(_table_type = nil)
          @connection.layers.map(&:name)
        end

        # Returns true if table exists.
        # If the schema is not specified as part of +name+ then it will only
        # find tables within the current schema search path (regardless of
        # permissions to access tables in other schemas).
        #
        # @param table_name [String]
        def table_exists?(table_name)
          return false if table_name.blank?

          !!@connection.layer_by_name(table_name)
        end
      end
    end
  end
end
