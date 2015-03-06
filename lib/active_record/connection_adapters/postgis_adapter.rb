require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'

require 'ffi-gdal'
GDAL::Logger.logging_enabled = true

require_relative '../../arel/visitors/postgis'
require_relative '../connection_handling'

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
require_relative 'postgresql/oid'

module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter
      include PostGISAdapter::DatabaseStatements
      include PostGISAdapter::SchemaStatements

      ADAPTER_NAME = 'PostGIS'.freeze

      POSTGIS_NATIVE_DATABASE_TYPES = {
        geometry: { name: 'geometry' }
      }

      # @param [Hash] connection_parameters Params gleaned from the
      #   database.yml, used for making the connection to PostgreSQL.
      # @param [Hash] config Other params used for configuring
      #   PostgreSQL/PostGIS.
      def initialize(connection, logger = nil, connection_parameters, config)
        super(connection, logger, connection_parameters, config)

        @connection_parameters, @config = connection_parameters, config
        connect

        @visitor = ::Arel::Visitors::PostGIS.new(self)
      end

      def connect
        ENV['PG_LIST_ALL_TABLES'] ||= 'YES'
        driver = OGR::Driver.by_name('PostgreSQL')
        @connection = driver.open(connection_string, 'r')
      end

      def disconnect!
        @connection.close
      end

      # @return [Hash]
      def native_database_types
        super.merge(POSTGIS_NATIVE_DATABASE_TYPES)
      end

      def exec_no_cache(sql, name, binds)
        log(sql, name, binds) { @connection.execute_sql(sql) }
      end

      # @return [Boolean]
      def active?
        exec_query 'SELECT 1'
        true
      rescue GDAL::NullObject
        false
      end

      protected

      # @return [Fixnum] The result of `SHOW server_version_num;`.
      def postgresql_version
        result = exec_query('SHOW server_version_num;')

        result.rows.first.first.to_i
      end

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
    end
  end
end
