require 'active_record/connection_adapters/postgresql/oid'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      module OID
        class Geometry
          def type_cast(value)
            puts "Geometry#type_cast: #{value}"
            value
          end
        end

        self.register_type 'geometry', Geometry.new
        puts 'registered!'
      end
    end
  end
end
