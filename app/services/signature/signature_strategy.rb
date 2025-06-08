module Signature
  module SignatureStrategy
    def sign(data)
      raise NotImplementedError, "sign method must be implemented."
    end

    def verify(data, signature)
      raise NotImplementedError, "verify method must be implemented."
    end
  end
end
