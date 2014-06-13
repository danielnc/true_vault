require 'base64'

module TrueVault
  module REST
    class API

      @@schemas_by_name_cache = {}

      def self.create_schema(name, fields)
        TrueVault.client.post("schemas", schema: Base64.strict_encode64({name: name, fields: fields}.to_json))
      end

      def self.update_schema(name, fields)
        schema = self.find_schema_by_name(name)

        @@schemas_by_name_cache.delete(name)

        raise TrueVault::Error::MissingSchema.new("#{name} is not a known schema name") if schema.nil?
        TrueVault.client.put("schemas/#{schema.id}", schema: Base64.strict_encode64({name: name, fields: fields}.to_json))
      end

      def self.find_schema_by_name(name)
        schema = @@schemas_by_name_cache[name]
        return schema if schema.present?

        response = TrueVault.client.get("schemas")
        schema = response.schemas.select { |schema| schema.name == name }.first

        @@schemas_by_name_cache[name] = schema
      end

      def self.destroy_schema_by_name(name)
        schema = self.find_schema_by_name(name)

        raise TrueVault::Error::MissingSchema.new("#{name} is not a known schema name") if schema.nil?
        self.destroy_schema_by_id(schema.id)
      end

      def self.destroy_schema_by_id(id)
        TrueVault.client.delete("schemas/#{id}")
      end

      def self.get_document(document_id)
        Base64.decode64(TrueVault.client.get("documents/#{document_id}", :do_not_force_load))
      end

      def self.get_documents(*document_ids)
        TrueVault.client.get("documents/#{document_ids.join(",")}").documents.map { |response| Base64.decode64(response.document) }
      end

      def self.create_document(index_name, attributes)
        schema = self.find_schema_by_name(index_name)
        TrueVault.client.post("documents", schema_id: schema.id, document: Base64.strict_encode64(attributes.to_json))
      end

      def self.search(schema_name, fields, options=nil)
        schema = self.find_schema_by_name(schema_name)

        schema_id = schema.present? ? schema.id : nil

        search_options = {
          filter: fields
        }

        search_options[:schema_id] = schema_id if schema_id.present?
        search_options.merge!(options) if options.present?

        TrueVault.client.get("", search_option: Base64.strict_encode64(search_options.to_json))
      end
    end
  end
end