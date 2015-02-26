require 'active_record/connection_handling'

module ActiveRecord
  module ConnectionHandling
    VALID_CONN_PARAMS = %i[
      active_schema
      dbname
      host
      password
      port
      schemas
      tables
      user
    ]

    def postgis_connection(config)
      puts "config: #{config}"
      puts "config params: #{VALID_CONN_PARAMS}"
      conn_params = config.symbolize_keys

      conn_params.delete_if { |_, v| v.nil? }

      # Map ActiveRecords param names to PGs.
      conn_params[:user] = conn_params.delete(:username) if conn_params[:username]
      conn_params[:dbname] = conn_params.delete(:database) if conn_params[:database]

      # Forward only valid config params to PGconn.connect.
      conn_params.keep_if { |k, _| VALID_CONN_PARAMS.include?(k) }
      ::ActiveRecord::ConnectionAdapters::PostGISAdapter.new(nil, logger, conn_params, config)
    end
  end
end
