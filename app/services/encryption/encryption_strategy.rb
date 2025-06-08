module Encryption
  module EncryptionStrategy
    def encrypt(value)
      raise NotImplementedError, "encrypt method must be implemented."
    end

    def decrypt(value)
      raise NotImplementedError, "decrypt method must be implemented."
    end
  end
end
