require_relative 'postgis_column'

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

        # @param [String] table_name
        # @return [Array<ActiveRecord::ConnectionAdapters::PostGISAdapter::PostGISColumn>]
        def columns(table_name)
          # Limit, precision, and scale are all handled by the superclass.
          column_definitions(table_name).map do |column_name, type, default, notnull, oid, fmod|
            oid = get_oid_type(oid.to_i, fmod.to_i, column_name)
            srid = nil

            if oid.class == ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID::Geometry
              /\Ageometry\((?<geometry_type>\w*),?(?<srid>\d*)\)/ =~ type
              srid = srid.to_i
            end

            PostGISColumn.new(column_name, default, oid, type, notnull == 'f', srid: srid)
          end
        end
      end
    end
  end
end
