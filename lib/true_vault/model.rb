require_relative 'rest/api'
module TrueVault
  class Model
    attr_reader :model, :true_vault_index, :options
    def initialize(model)
      @model = model
      @true_vault_index = model.class.true_vault_index
      @options = model.true_vault_options
    end

    def create!
      api.create_document(options[:index_name], get_true_vault_schema_attributes).document_id
    end

    def delete!
      api.destroy_schema_by_name(options[:index_name])
    end

    def update!
      api.update_schema(options[:index_name], get_true_vault_schema_attributes)
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
      Hash[true_vault_index.options[:fields].map do |field, options|
        [field, format_value(options[:type], model.send(field))]
      end]
    end

    def format_value(type, value)
      return value if value.blank?

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
