require_relative 'rest/api'
require_relative 'results'
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
      api.delete_document(options[:index_name], model.true_vault_document_id)
    end

    def update!
      api.update_document(options[:index_name], model.true_vault_document_id, get_true_vault_schema_attributes).document_id
    end

    def exists?
      begin
        api.get_document(model.true_vault_document_id)
        true
      rescue TrueVault::Error
        return false if $!.response[:status] == 404
        raise $!
      end
    end

    def self.search(klazz, index_name, filters, search_options={})
      Results.new(klazz, api.search(index_name, filters, search_options))
    end

    protected
    def get_true_vault_schema_attributes
      klazz = options[:klazz]
      Hash[true_vault_index.options[:fields].map do |field, options|
        [field, format_value(options[:type], model.send(field).presence)]
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
