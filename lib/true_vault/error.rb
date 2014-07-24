module TrueVault
  class Error < StandardError
    class MissingField < self; end
    class MissingVirtualFieldType < self; end
    class WrongVirtualFieldType < self; end
    class MissingSchema < self; end
    class ClientError < self; end
    class RequestTimeout < self; end
    class WrongFilterValues < self; end

    def from_response(response)
      message, code = parse_error(response.body)
      new(message, response.response_headers, code)
    end

    private
    def parse_error(body)
      if body.nil?
        ['', nil]
      elsif body[:error]
        [body[:error], nil]
      elsif body[:errors]
        extract_message_from_errors(body)
      end
    end

    def extract_message_from_errors(body)
      first = Array(body[:errors]).first
      if first.is_a?(Hash)
        [first[:message].chomp, first[:code]]
      else
        [first.chomp, nil]
      end
    end
  end
end