class CryptoController < ApplicationController
  wrap_parameters false

  def encrypt
    return render json: { error: "No payload provided" }, status: :bad_request unless request.body.read.present?

    payload = JSON.parse(request.body.read)
    return render json: { error: "Invalid request format" }, status: :bad_request unless payload.is_a?(Hash)

    encryptor = Encryption::Base64Encryption.new
    encrypted_request = payload.transform_values { |value| encryptor.encrypt(value) }

    render json: encrypted_request
  rescue JSON::ParserError
    render json: { error: "Invalid JSON" }, status: :bad_request
  end
end
