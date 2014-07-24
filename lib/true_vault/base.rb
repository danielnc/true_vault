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
          after_commit :reindex, if: proc{ self.class.search_callbacks? }
        else
          after_save :reindex, if: proc{ self.class.search_callbacks? }
          after_destroy :reindex, if: proc{ self.class.search_callbacks? }
        end

        def self.enable_search_callbacks
          class_variable_set :@@true_vault_callbacks, true
        end

        def self.disable_search_callbacks
          class_variable_set :@@true_vault_callbacks, false
        end

        def self.search_callbacks?
          class_variable_get(:@@true_vault_callbacks)
        end

        def reindex
          if destroyed?
            self.remove_true_vault_document
          else
            self.store_true_vault_document
          end
        end

        def store_true_vault_document
          method = @true_vault_new_record ? :create! : :update!

          self.update_column(:document_id, true_vault_model.send(method))
        end

        def self.search(fields, options={})
          Model.search(true_vault_options[:index_name], fields, options).map do |document_id|
            self.find_by_document_id(document_id)
          end.compact
        end

        private
        def true_vault_model
          Model.new(self)
        end
      end
    end
  end
end
