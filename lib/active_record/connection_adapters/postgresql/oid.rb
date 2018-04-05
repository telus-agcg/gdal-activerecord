require 'active_record/connection_adapters/postgresql/oid'
require 'ogr/geometry'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      module OID
        class Geometry < Type::Value
          include Type::Mutable

          def initialize(type_map)
            @sql_type = type_map
          end

          def type
            :geometry
          end

          # Preps the OGR::Geometry to be put in the database.
          #
          # @param value [OGR::Geometry]
          # @return [String]
          def type_cast_for_database(value)
            value.to_ewkb if value.is_a?(::OGR::Geometry)
          end

          private

          # Defines how to marshal the value from the database to a Ruby object.
          # In our case, this should return an OGR::Geometry.
          #
          # Type::Value#type_cast_from_user and
          # Type::Value#type_cast_from_database both call this (through
          # Type::Value#type_cast).
          #
          # @param value [String, nil] The bytea/EWKB stored in the database.
          # @return [OGR::Geometry]
          def cast_value(value)
            binary_value = if %W[\x00 \x01].include? value[0]
                             value
                           else
                             [value].pack('H*')
                           end

            OGR::Geometry.create_from_ewkb(binary_value)
          end
        end
      end
    end
  end
end
