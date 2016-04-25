require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'
require 'ffi-gdal'
# GDAL::Logger.logging_enabled = true
require 'pg'

require_relative '../../arel/visitors/postgis'
require_relative '../connection_handling'
require_relative 'postgresql/oid'

module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter < ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
    end
  end
end

require_relative 'postgis_adapter/database_statements'
require_relative 'postgis_adapter/schema_statements'
require_relative 'postgis_adapter/postgis_column'
require_relative 'postgis_adapter/table_definition'
require_relative 'postgis_adapter/quoting'
require_relative '../tasks/database_tasks'

module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter
      include PostGISAdapter::DatabaseStatements
      include PostGISAdapter::SchemaStatements
      include PostGISAdapter::Quoting

      ADAPTER_NAME = 'PostGIS'.freeze

      POSTGIS_NATIVE_DATABASE_TYPES = {
        geometry: { name: 'geometry' }
      }.freeze

      # @param [Hash] connection_parameters Params gleaned from the
      #   database.yml, used for making the connection to PostgreSQL.
      # @param [Hash] config Other params used for configuring
      #   PostgreSQL/PostGIS.
      def initialize(*args)
        super

        @visitor = ::Arel::Visitors::PostGIS.new(self)
      end

      # @return [Hash]
      def native_database_types
        super.merge(POSTGIS_NATIVE_DATABASE_TYPES)
      end

      # @return [Boolean]
      def active?
        exec_query 'SELECT 1'
        true
      rescue GDAL::NullObject
        false
      end

      # @param table_name [String]
      # @param options [Hash]
      # @option options [] temporary
      # @option options [] options
      # @option options [] as
      # @option options [] force
      # def create_table(table_name, **options)
      #   postgis_table_definition = create_table_definition(
      #     table_name,
      #     options[:temporary],
      #     options[:options],
      #     options[:as])
      #
      #   super(table_name, options) do |super_table_definition|
      #     super_table_definition = postgis_table_definition
      #   end
      # end

      protected

      # @return [String] The full result of PostGIS_Version(). ex. "2.1
      #   USE_GEOS=1 USE_PROJ=1 USE_STATS=1"
      def postgis_version
        result = exec_query('SELECT PostGIS_Version();')

        result.rows.first.first.to_s
      end

      private

      # The take the form:
      #   PG:"dbname='databasename' host='addr' port='5432' user='x' password='y'"
      #
      # @return [String]
      def connection_string
        return '' if @connection_parameters.empty?

        @connection_parameters.each_with_object('PG:') do |(k, v), s|
          s << "#{k}=#{v} "
        end
      end

      # @param table_name [String]
      # @param temporary
      # @param options [Hash]
      # @param as
      # @return [ActiveRecord::ConnectionAdapters::PostGISAdapter::TableDefinition]
      # def create_table_definition(table_name, temporary, options, as = nil)
      #   puts "#create_table_definition, name: #table_{name}"
      #   puts "#create_table_definition, temporary: #{temporary}"
      #   puts "#create_table_definition, options: #{options}"
      #   puts "#create_table_definition, as: #{as}"
      #   PostGISAdapter::TableDefinition.new(native_database_types, table_name, temporary, options, as)
      # end
    end
  end
end
