require_relative 'rest/api'
module TrueVault
  class Index
    attr_reader :options
    def initialize(options)
      @options = normalize_options(options)
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

    protected
    def normalize_options(options)
      validate_options(options)

      options[:fields] = Hash[options[:fields].map do |field, field_options|
        [
          field,
          {
            index: field_options[:index] || false,
            type: transform_field_type((field_options[:type].presence || options[:klazz].columns_hash[field.to_s].type).to_sym)
          }
        ]
      end]

      options
    end

    def fields_to_schema
      schema = []
      klazz = options[:klazz]
      options[:fields].each do |field, field_options|
        schema << {name: field, index: field_options[:index], type: field_options[:type]}
      end

      schema
    end

    def transform_field_type(type)
      case type
      when :date, :datetime, :time
        :date
      else
        type
      end
    end

    def validate_options(options)
      raise TrueVault::Error::MissingField.new("Missing mandatory parameter fields or fields must be an Array") if options[:fields].nil? || !options[:fields].kind_of?(Hash)
      valid_types = %w(boolean date datetime decimal float integer string text time timestamp)

      options[:fields].each do |field, field_options|
        if options[:klazz].columns_hash[field.to_s].nil? && field_options[:type].nil?
          raise TrueVault::Error::MissingVirtualFieldType.new("Virtual field #{options[:klazz].name}##{field} needs a type")
        elsif options[:klazz].columns_hash[field.to_s].nil? && valid_types.index(field_options[:type].to_s).nil?
          raise TrueVault::Error::WrongVirtualFieldType.new("Virtual field #{options[:klazz].name}##{field} needs to be one of the following: #{valid_types.join(", ")}")
        end
      end
    end

    def api
      TrueVault::REST::API
    end
  end
end
