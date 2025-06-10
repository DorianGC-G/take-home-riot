module Encryption
  class Base64Encryption
    def encrypt(value)
      case value
      when String
        Base64.strict_encode64(value)
      when Numeric
        Base64.strict_encode64(value.to_s)
      when Hash, Array
        Base64.strict_encode64(value.to_json)
      else
        raise ArgumentError, "Unsupported value type for encryption."
      end
    end

    def decrypt(value)
      return value unless value.is_a?(String)

      begin
        decoded = Base64.strict_decode64(value)
        # Try to parse as JSON, fallback to string or integer
        JSON.parse(decoded)
      rescue JSON::ParserError
        # Try to convert to integer if possible
        Integer(decoded) rescue decoded
      rescue ArgumentError
        value # If not valid Base64, return as is
      end
    end
  end
end
