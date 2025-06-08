class CryptoController < ApplicationController
  wrap_parameters false

  def encrypt
    payload = JSON.parse(request.body.read)
    encryptor = Encryption::Base64Encryption.new
    encrypted_request = payload.transform_values { |value| encryptor.encrypt(value) }

    render json: encrypted_request
  rescue JSON::ParserError
    render json: { error: "Invalid JSON" }, status: :bad_request
  end

  def decrypt
    payload = JSON.parse(request.body.read)
    encryptor = Encryption::Base64Encryption.new
    decrypted_request = payload.transform_values { |value| encryptor.decrypt(value) }

    render json: decrypted_request
  rescue JSON::ParserError
    render json: { error: "Invalid JSON" }, status: :bad_request
  end
end
