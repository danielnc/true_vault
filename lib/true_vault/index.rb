require_relative 'rest/api'
module TrueVault
  class Index
    attr_reader :options
    def initialize(options)
      @options = options
    end

    def create!
      api.create_schema(options[:index_name], fields_to_schema)
    end

    def delete!
      api.destroy_schema_by_name(options[:index_name])
    end

    def update!
      api.update_schema(options[:index_name], fields_to_schema)
    end

    def exists?
      api.find_schema_by_name(options[:index_name]).present?
    end

    def schema_fields
      options[:fields].keys.map(&:to_s)
    end

    protected
    def fields_to_schema
      schema = []
      klazz = options[:klazz]
      options[:fields].each do |field, options|
        schema << {name: field, index: options[:index] || false, type: transform_field_type(field)}
      end

      schema
    end

    def transform_field_type(field)
      type = options[:klazz].columns_hash[field.to_s].type
      case type
      when :date, :datetime, :time
        :date
      else
        type
      end
    end
    def api
      TrueVault::REST::API
    end
  end
end
