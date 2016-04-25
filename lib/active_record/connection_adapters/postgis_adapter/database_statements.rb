require 'active_record/connection_adapters/postgresql/database_statements'

module ActiveRecord
  module ConnectionAdapters
    class PostGISAdapter
      module DatabaseStatements
        if ActiveRecord::VERSION::STRING < '4.2'
          include ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::DatabaseStatements
        else
          include ActiveRecord::ConnectionAdapters::PostgreSQL::DatabaseStatements
        end

        private

        def exec_query_with_ogr(sql, name, binds)
          layer = if without_prepared_statement?(binds)
                    exec_no_cache(sql, name, binds)
                  else
                    exec_cache(sql, name, binds)
          end

          rows = extract_rows(layer)
          columns = extract_column_names(layer)
          types = extract_column_types(layer)

          @connection.release_result_set(layer)

          ActiveRecord::Result.new(columns, rows, types)
        end

        # Gets all of the column names from the OGR::Layer (which is the result
        # of the SQL query). Names are retrieved from FieldDefinitions and
        # GeometryFieldDefinitions, then concatenated into a single array.
        #
        # @param [OGR::Layer] layer The result of the SQL query.
        # @return [Array<String>]
        def extract_column_names(layer)
          return [] if layer.nil?

          field_names = Array.new(layer.feature_definition.field_count)
          geometry_field_names = Array.new(layer.feature_definition.geometry_field_count)

          layer.feature_definition.field_definitions.each do |fd|
            field_def_index = layer.feature_definition.field_index(fd.name)
            field_names[field_def_index] = fd.name
          end

          layer.feature_definition.geometry_field_definitions.each do |gfd|
            geometry_field_def_index = layer.feature_definition.geometry_field_index(gfd.name)
            geometry_field_names[geometry_field_def_index] = gfd.name
          end

          field_names + geometry_field_names
        end

        # @param [OGR::Layer] layer
        # @return [Hash{OGR::GeometryFieldDefinition#name,OGR::FieldDefinition#name =>
        #   PostgreSQLAdapter::OID::Geometry}]
        def extract_column_types(layer)
          return {} if layer.nil?

          extract_non_geometric_types(layer).merge(extract_geometric_types(layer))
        end

        # @param [OGR::Layer] layer
        # @return [Hash{OGR::GeometryFieldDefinition#name => PostgreSQLAdapter::OID::Geometry}]
        def extract_geometric_types(layer)
          return {} if layer.nil?

          layer.feature_definition.geometry_field_definitions.each_with_object({}) do |geometry_field_definition, o|
            o[geometry_field_definition.name] = PostgreSQLAdapter::OID::Geometry.new
          end
        end

        # @param [OGR::Layer] layer
        # @return [Hash{OGR::FieldDefinition#name => PostgreSQLAdapter::OID}]
        def extract_non_geometric_types(layer)
          return {} if layer.nil?

          layer.feature_definition.field_definitions.each_with_object({}) do |field_definition, o|
            o[field_definition.name] =
              case field_definition.type
              when :OFTInteger        then PostgreSQLAdapter::OID::Integer.new
              when :OFTIntegerList    then PostgreSQLAdapter::OID::Array.new('integer')
              when :OFTReal           then PostgreSQLAdapter::OID::Float.new
              when :OFTRealList       then PostgreSQLAdapter::OID::Array.new('float')
              when :OFTString         then PostgreSQLAdapter::OID::Identity.new
              when :OFTStringList     then PostgreSQLAdapter::OID::Array.new('string')
              when :OFTWideString     then PostgreSQLAdapter::OID::Identity.new
              when :OFTWideStringList then PostgreSQLAdapter::OID::Array.new('string')
              when :OFTBinary         then PostgreSQLAdapter::OID::Bytea.new
              when :OFTDate           then PostgreSQLAdapter::OID::Date.new
              when :OFTTime           then PostgreSQLAdapter::OID::Time.new
              when :OFTDateTime       then PostgreSQLAdapter::OID::Timestamp.new
              when :OFTInteger64      then PostgreSQLAdapter::OID::Integer.new
              when :OFTInteger64List  then PostgreSQLAdapter::OID::Array.new('integer')
              when :OFTMaxType        then PostgreSQLAdapter::OID::Date.new
              else
                puts "not sure about fd type: #{fd.type}"
              end
          end
        end

        # Column values
        # @param [OGR::Layer] layer
        # @return [Array<Array<String>>] A 2d array, where the each element of
        #   the parent array is an array that represents values for each column.
        def extract_rows(layer)
          return [[]] if layer.nil?

          rows = []
          layer.reset_reading
          feature = layer.next_feature

          until feature.nil?
            row = []
            row += feature.fields.map do |field|
              field
            end

            row << feature.geometry
            feature = layer.next_feature
            rows << row
          end

          rows
        end
      end
    end
  end
end
