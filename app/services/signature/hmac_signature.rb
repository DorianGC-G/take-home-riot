module Signature
  class HmacSignature
    # Using SHA256 as the default hashing algorithm
    def initialize(secret_key = nil)
      @secret_key = secret_key || "default_secret_key"
    end

    def sign(data)
      # Sort the hash keys to ensure consistent signatures regardless of key order
      standardized_data = standardize(data)

      # Generate HMAC signature
      OpenSSL::HMAC.hexdigest("SHA256", @secret_key, standardized_data)
    end

    def verify(data, signature)
      expected_signature = sign(data)

      ActiveSupport::SecurityUtils.secure_compare(expected_signature, signature)
    end

    private

    def standardize(input)
      case input
      when Hash
        sorted_hash = input.sort.to_h
        JSON.generate(sorted_hash.transform_values { |element| standardize_element(element) })
      when Array
        JSON.generate(input.map { |element| standardize_element(element) })
      else
        input.to_s
      end
    end

    def standardize_element(element)
      case element
      when Hash, Array
        standardize(element)
      else
        element
      end
    end
  end
end
