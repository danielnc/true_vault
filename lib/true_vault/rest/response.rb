require 'ostruct'

module TrueVault
  module REST
    class Response < OpenStruct
      def id
        @table[:id]
      end

      def type
        @table[:type]
      end

      def <=>(another_response)
        keys_diff = @table.keys <=> another_response.table.keys
        case keys_diff
        when 0
          @table.values <=> another_response.table.values
        else
          keys_diff
        end
      end

      def self.load(item)
        raise ArgumentError, "#{self.class.name} must be passed a Hash or Array" unless(item.is_a?(Hash) || item.is_a?(Array))
        if(item.is_a?(Hash))
          item = item.merge(item) do |key, value, oldvalue|
            if(value.is_a?(Hash) || value.is_a?(Array))
              Response.load(value)
            else
              value
            end
          end
          return self.new(item)
        elsif(item.is_a?(Array))
          return item.map do |value|
            if(value.is_a?(Hash) || value.is_a?(Array))
              Response.load(value)
            else
              value
            end
          end
        end
      end
    end
  end
end
