require_relative 'rest/api'
module TrueVault
  class Model
    attr_reader :attributes, :options
    def initialize(attributes, options)
      @attributes = attributes
      @options = options
    end

    def create!
      api.create_document(options[:index_name], get_true_vault_schema_attributes).document_id
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

    def self.search(index_name, filters, search_options={})
      api.search(index_name, filters, search_options).data.documents
    end

    protected
    def get_true_vault_schema_attributes
      klazz = options[:klazz]
      Hash[attributes.slice(*klazz.true_vault_index.schema_fields).map do |field, value|
        [field, format_value(klazz.columns_hash[field.to_s].type, value)]
      end]
    end

    def format_value(type, value)
      return value if value.nil?

      case type
      when :date, :datetime, :time
        time_value = value.to_time if value.respond_to?(:to_time)
        time_value ||= value
        time_value.strftime("%FT%T")
      else
        value
      end
    end

    def self.api
      TrueVault::REST::API
    end
    def api
      TrueVault::REST::API
    end
  end
end
