require 'active_record'
require 'active_record/connection_adapters/abstract_adapter'
require 'active_record/connection_adapters/statement_pool'
require 'ffi-gdal'
GDAL::Logger.logging_enabled = true

require_relative '../../arel/visitors/postgis'
require_relative '../connection_handling'

module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter < AbstractAdapter
    end
  end
end

require_relative 'postgresql_adapter_methods'
require_relative 'postgis_adapter/database_statements'
require_relative 'postgis_adapter/schema_statements'
require_relative 'postgis_adapter/table_definition'

module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter
      include PostgreSQLAdapterMethods
      include PostGISAdapter::DatabaseStatements
      include PostGISAdapter::SchemaStatements

      ADAPTER_NAME = 'PostGIS'.freeze

      # @param [Hash] connection_parameters Params gleaned from the
      #   database.yml, used for making the connection to PostgreSQL.
      # @param [Hash] config Other params used for configuring
      #   PostgreSQL/PostGIS.
      def initialize(connection, logger = nil, connection_parameters, config)
        super(connection, logger)

        @visitor = ::Arel::Visitors::PostGIS.new(self)
        @connection_parameters, @config = connection_parameters, config
        connect
      end

      def connect
        ENV['PG_LIST_ALL_TABLES'] ||= 'YES'
        driver = OGR::Driver.by_name('PostgreSQL')
        puts "connecting with string: #{connection_string}"
        @connection = driver.open(connection_string, 'r')
      end

      # @return [Hash{Symbol => Hash{name => String}}]
      def native_database_types
        NATIVE_DATABASE_TYPES
      end

      def supports_migrations?
        true
      end

      def supports_primary_key?
        true
      end

      # TODO: figure out
      def supports_insert_with_returning?
        true
      end

      # TODO: figure out
      def supports_ddl_transactions?
        true
      end

      # TODO: figure out
      def supports_explain?
        true
      end

      # TODO: figure out
      def supports_extensions?
        postgresql_version >= 90100
      end

      def supports_ranges?
        postgresql_version >= 90200
      end

      def select(sql, name = nil, binds = [])
        exec_query(sql, name, binds)
      end

      def exec_no_cache(sql, name, binds)
        log(sql, name, binds) { @connection.execute_sql(sql) }
      end

      def column_types
        puts "column types"
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
