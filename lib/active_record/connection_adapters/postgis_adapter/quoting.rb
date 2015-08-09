module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter
      module Quoting
        def quote_string(string)
          string
        end
      end
    end
  end
end
