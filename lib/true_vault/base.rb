require_relative 'index'
require_relative 'model'
require_relative 'error'

module TrueVault
  module Base

    def true_vault(options = {})
      raise "Only call true_vault once per model" if respond_to?(:true_vault_index)

      class_eval do
        cattr_reader :true_vault_options

        class_variable_set :@@true_vault_options, HashWithIndifferentAccess.new(options.dup.merge({
          klazz: self,
          index_name: options[:index_name].present? ? options[:index_name] : [options[:index_prefix], model_name.plural, ENV["RACK_ENV"] || ENV["RAILS_ENV"] || "development"].compact.join("_")
          }))
        class_variable_set :@@true_vault_callbacks, options[:callbacks] != false

        def self.true_vault_index
          Index.new(true_vault_options)
        end

        before_create { @true_vault_new_record = true }
        if respond_to?(:after_commit)
          after_commit :true_vault_reindex, if: proc{ self.class.true_vault_search_callbacks? }
        else
          after_save :true_vault_reindex, if: proc{ self.class.true_vault_search_callbacks? }
          after_destroy :true_vault_reindex, if: proc{ self.class.true_vault_search_callbacks? }
        end

        def self.true_vault_enable_search_callbacks
          class_variable_set :@@true_vault_callbacks, true
        end

        def self.true_vault_disable_search_callbacks
          class_variable_set :@@true_vault_callbacks, false
        end

        def self.true_vault_search_callbacks?
          class_variable_get(:@@true_vault_callbacks)
        end

        def true_vault_reindex(force=false)
          if self.destroyed?
            if self.respond_to?(:delay)
              self.delay(to: :true_vault_update).remove_true_vault_document
            else
              self.remove_true_vault_document
            end
          else
            if self.respond_to?(:delay)
              self.delay(to: :true_vault_update).store_true_vault_document(force)
            else
              self.store_true_vault_document(force)
            end
          end
        end

        def store_true_vault_document(recreate_true_vault_documents)
          method = @true_vault_new_record || recreate_true_vault_documents || self.true_vault_document_id.nil? ? :create! : :update!

          self.update_column(:true_vault_document_id, true_vault_model.send(method))
        end

        def remove_true_vault_document
          true_vault_model.delete!
        end

        def self.true_vault_search(fields, options={})
          options = HashWithIndifferentAccess.new(options)

          Model.search(self, true_vault_options[:index_name], fields, options)
        end

        private
        def true_vault_model
          Model.new(self)
        end
      end
    end
  end
end
