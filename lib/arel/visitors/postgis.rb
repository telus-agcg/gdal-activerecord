module Arel
  module Visitors
    class PostGIS < PostgreSQL
    end

    VISITORS['postgis'] = ::Arel::Visitors::PostGIS
  end
end
