require_relative 'postgis_column'
require_relative '../postgresql/oid'

module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter
      module SchemaStatements
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

        def initialize_type_map(map)
          super

          %w[
            geometry
            point multi_point
            line_string linear_ring multi_line_string
            polygon multi_polygon
            geometry_collection
          ].each do |geo_type|
            map.register_type(geo_type) do |_oid, _meow, sql_type|
              puts "_meow is #{_meow.inspect}"
              PostgreSQLAdapter::OID::Geometry.new(sql_type)
            end
          end
        end
      end
    end
  end
end
