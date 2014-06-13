require 'base64'
require 'faraday'
require 'faraday/request/multipart'
require 'faraday_middleware'
require 'json'
require 'timeout'
require_relative 'response'

module TrueVault
  module REST
    class Client
      URL_PREFIX = 'https://api.truevault.com'
      attr_accessor :api_key, :api_version, :vault_id
      attr_writer :user_agent

      def initialize(options = {})
        options.each do |key, value|
          send(:"#{key}=", value)
        end
        yield(self) if block_given?
        # validate_credentials!
      end

      def user_agent
        @user_agent ||= "TrueVault Ruby Gem #{TrueVault::VERSION}"
      end

      def credentials
        {
          :api_key     => consumer_key,
          :api_version => consumer_secret,
          :vault_id    => access_token,
        }
      end

      def connection_options
        @connection_options ||= {
          :builder => middleware,
          :headers => {
            :user_agent => user_agent,
          },
          :request => {
            :open_timeout => 10,
            :timeout => 30,
          }
        }
      end

      # @note Faraday's middleware stack implementation is comparable to that of Rack middleware.  The order of middleware is important: the first middleware on the list wraps all others, while the last middleware is the innermost one.
      # @see https://github.com/technoweenie/faraday#advanced-middleware-usage
      # @see http://mislav.uniqpath.com/2011/07/faraday-advanced-http/
      # @return [Faraday::RackBuilder]
      def middleware
        @middleware ||= Faraday::RackBuilder.new do |faraday|
          # Encodes as "application/x-www-form-urlencoded" if not already encoded
          faraday.request :url_encoded
          # Handle error responses
          faraday.response :raise_error
          # Set default HTTP adapter
          faraday.adapter :net_http
          # JSON
          faraday.response :json, :content_type => /\bjson$/
        end
      end

      # Perform an HTTP GET request
      def get(path, params = {})
        request(:get, path, params)
      end

      # Perform an HTTP POST request
      def post(path, params = {})
        request(:post, path, params)
      end

      # Perform an HTTP PUT request
      def put(path, params = {})
        request(:put, path, params)
      end

      # Perform an HTTP DELETE request
      def delete(path, params = {})
        request(:delete, path, params)
      end
    private
      # Returns a Faraday::Connection object
      #
      # @return [Faraday::Connection]
      def connection
        @connection ||= Faraday.new("#{URL_PREFIX}", connection_options) do |conn|
          conn.basic_auth(api_key, nil)
        end
      end

      def request(method, path, params = {}, headers = {})
        if params == :do_not_force_load
          params = {}
          do_not_force_load = true
        end
        body = connection.send(method.to_sym, "/#{api_version}/vaults/#{vault_id}/#{path}", params).env.body
        # do not response load
        return body if do_not_force_load

        Response.load(body)
      rescue Faraday::Error::TimeoutError, Timeout::Error => error
        raise(TrueVault::Error::RequestTimeout.new(error))
      rescue Faraday::Error::ClientError, JSON::ParserError => error
        puts error.response
        raise(TrueVault::Error.new(error))
      end
    end
  end
end