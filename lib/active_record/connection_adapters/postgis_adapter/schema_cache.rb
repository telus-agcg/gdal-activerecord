module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter
      class SchemaCache < ActiveRecord::ConnectionAdapters::SchemaCache
        def initialize(connection)
          super
        end

        def primary_keys(table_name)
          r = @connection.execute <<-SQL
SELECT a.attname
FROM   pg_index i
JOIN   pg_attribute a ON a.attrelid = i.indrelid
                     AND a.attnum = ANY(i.indkey)
WHERE  i.indrelid = '#{table_name}'::regclass
AND    i.indisprimary;
          SQL

          r.flatten
        end
      end
    end
  end
end
