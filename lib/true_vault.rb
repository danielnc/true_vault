require "active_model"
require "hashie"
require "true_vault/version"
require "true_vault/rest/client"
require "true_vault/base"

module TrueVault
  def self.client
    @client ||= REST::Client.new do |client|
      client.api_key = ENV["TRUE_VAULT_API_KEY"]
      client.api_version = ENV["TRUE_VAULT_API_VERSION"] || "v1"
      client.vault_id = ENV["TRUE_VAULT_VAULT_ID"]
    end
  end

  def self.client=(client)
    @client = client
  end

  @callbacks = true

  def self.enable_callbacks
    @callbacks = true
  end

  def self.disable_callbacks
    @callbacks = false
  end

  def self.callbacks?
    @callbacks
  end
end

# TODO find better ActiveModel hook
ActiveModel::Callbacks.send(:include, TrueVault::Base)
ActiveRecord::Base.send(:extend, TrueVault::Base) if defined?(ActiveRecord)
