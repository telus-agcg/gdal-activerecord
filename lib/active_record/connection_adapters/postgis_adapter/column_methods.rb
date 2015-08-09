module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter
      module ColumnMethods
        def geometry(name, **options)
          puts 'in #geometry'
          column(name, 'geometry', options)
        end
      end
    end
  end
end
