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

      def self.update_document(index_name, document_id, attributes)
        schema = self.find_schema_by_name(index_name)
        TrueVault.client.put("documents/#{document_id}", schema_id: schema.id, document: Base64.strict_encode64(attributes.to_json))
      end

      def self.delete_document(index_name, document_id)
        schema = self.find_schema_by_name(index_name)
        TrueVault.client.delete("documents/#{document_id}", schema_id: schema.id)
      end

      def self.search(schema_name, fields, options=nil)
        schema = self.find_schema_by_name(schema_name)

        schema_id = schema.present? ? schema.id : nil

        if options.delete(:case_insensitive)
          fields.each do |k, v|
            fields[k] = if v.kind_of?(Hash)
                          v.with_indifferent_access.reverse_merge(case_sensitive: false, type: :eq)
                        else
                          {
                            value: v,
                            case_sensitive: false,
                            type: :eq
                          }
                        end
          end
        end

        fields.each do |k, v|
          v = { value: v, type: :eq } unless v.kind_of?(Hash)
          fields[k] = v = v.with_indifferent_access


          if v[:wildcard].present?
            fields[k] = v.merge(type: :wildcard)
            fields[k].delete(:wildcard)
          elsif v[:range].present?
            fields[k] = {
              type: :range,
              value: {
                gte: v[:value][0],
                lte: v[:value][1]
              }
            }
            fields[k].delete(:range)
          elsif v[:value].kind_of?(Array) && v[:type] == :eq
            fields[k] = v.merge(type: :in)
          end
        end

        search_options = {
          filter: fields
        }

        search_options[:schema_id] = schema_id if schema_id.present?
        search_options.merge!(options) if options.present?

        # TODO UGLY HACK TO LIMIT THE SIZE OF TRUE VAULT QUERY... REMOVE THIS WHEN TV FIX IT ON THEIR SIDE
        # SEARCH FOR: UGLY HACK TO FIND WHERE ELSE TO REMOVE
        if ((search_options[:filter][:id] || {})[:value] || []).any?
          id_filter = search_options[:filter].delete(:id)
          cloned_filter = id_filter.clone

          results = id_filter[:value].each_slice(250).map do |split_ids|
            cloned_filter[:value] = split_ids
            search_options[:filter][:id] = cloned_filter

            TrueVault.client.get("", search_option: Base64.strict_encode64(search_options.to_json), do_not_force_load: true)
          end

          response = {}
          results.each do |result|
            self.hash_deep_merge!(response, result) do |key, oldval, newval|
              if (newval.kind_of?(Numeric) || newval.kind_of?(Array)) && %w(per_page current_page).index(key).nil?
                newval + oldval
              else
                newval
              end
            end
          end

          TrueVault::REST::Response.load(response)
        else
          TrueVault.client.get("", search_option: Base64.strict_encode64(search_options.to_json))
        end
      end

      # There is a bug in Hash.deep_merge that is not working, this is a re-implementation that works...
      def self.hash_deep_merge!(first_hash, other_hash, &block)
        other_hash.each_pair do |current_key, other_value|
          this_value = first_hash[current_key]

          first_hash[current_key] = if this_value.is_a?(Hash) && other_value.is_a?(Hash)
            self.hash_deep_merge!(this_value, other_value, &block)
          else
            if block_given? && first_hash.key?(current_key)
              block.call(current_key, this_value, other_value)
            else
              other_value
            end
          end
        end
        first_hash
      end
    end
  end
end