require 'active_record/connection_adapters/postgresql/oid'
require 'ogr/geometry'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      module OID
        class Geometry
          # TODO: need to support WKB.
          def type_cast(value)
            return if value.nil?

            OGR::Geometry.create_from_wkt(value.to_s)
          end
        end

        register_type 'geometry', Geometry.new
      end
    end
  end
end
