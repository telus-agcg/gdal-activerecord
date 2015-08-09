require_relative 'column_methods'

module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter
      class TableDefinition
        include ColumnMethods

        def column(name, type = nil, **options)
          puts 'column called'
          super
        end
      end
    end
  end
end
