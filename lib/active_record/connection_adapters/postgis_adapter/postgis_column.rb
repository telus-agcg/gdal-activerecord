require_relative '../postgresql/oid'
require 'ogr/geometry'
require 'ogr/spatial_reference'

module ActiveRecord
  module ConnectionAdapters
    class PostGISColumn < PostgreSQLColumn
      # @param [String] WKT that represents the geometry.
      # @param [Fixnum] ID of the EPSG spatial reference.
      # @return [OGR::Geometry]
      def self.convert_to_geometry(value, srid)
        geometry = OGR::Geometry.create_from_wkt(value)

        if geometry.nil?
          fail OGR::InvalidGeometry, "Unable to create geometry from '#{value}'"
        end

        geometry.spatial_reference = OGR::SpatialReference.new_from_epsg(srid)

        geometry
      end

      # @param [String] column_name
      # @param [String] default
      # @param [ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID] oid_type
      # @param [String] sql_type i.e. 'double precision', 'json',
      #   'geometry(MultiPolygon,3857)'.
      def initialize(column_name, default, oid_type, sql_type = nil, null = true, srid: nil)
        super(column_name, default, oid_type, sql_type, null)
        @srid = srid
      end

      # Is the column a geometry? (Not sure if this should encompass geographys
      # as well)
      #
      # @return [Boolean]
      def geometry?
        !!(@sql_type =~ /\Ageometry/)
      end

      # TODO: implement geographys
      def geography?
        false
      end

      # Is this a geometry or a geography?
      #
      # @return [Boolean]
      def spatial?
        geometry? || geography?
      end

      # Is this a raster?
      #
      # @return [Boolean]
      def raster?
        !!(@sql_type =~ /\Araster/)
      end

      # Is this a regular ol' PostgreSQL column?
      #
      # @return [Boolean]
      def non_gis?
        !!spatial? && !!raster?
      end

      # @param [Object] value The value to cast to a PostGIS value.
      # @return [OGR::Geometry, GDAL::Dataset]
      def type_cast(value)
        return super if non_gis? || value.blank?

        if spatial? then self.class.convert_to_geometry(value, @srid)
        elsif raster?
        end
      end

      # @return [Class] Class that represents the column value Ruby type. If it's
      #   a geometry/geography, it'll return an OGR::Geometry. If it's a raster,
      #   it'll be a GDAL::Dataset.
      def klass
        if geometry? then OGR::Geometry
        elsif raster? then GDAL::Dataset
        else super
        end
      end

      private

      # @param [String] field_type The internal type that Postgres uses to
      #   describe the column data type.
      def simplified_type(field_type)
        case field_type
        when /\Ageometry\(\z/
          :geometry
        when 'raster'
          :raster
        else
          super
        end
      end
    end
  end
end
