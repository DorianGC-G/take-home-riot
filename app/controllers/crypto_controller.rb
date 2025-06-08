class CryptoController < ApplicationController
  # Prevent Rails from wrapping the request body in a hash
  # This is a workaround to allow us to use the raw body in the controller instead of the usual params hash
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

  def sign
    payload = JSON.parse(request.body.read)
    signer = Signature::HmacSignature.new
    signature = signer.sign(payload)

    render json: { signature: signature }
  rescue JSON::ParserError
    render json: { error: "Invalid JSON" }, status: :bad_request
  end

  def verify
    payload = JSON.parse(request.body.read)

    # Check if payload has required fields
    unless payload.key?("signature") && payload.key?("data")
      return render json: { error: "Missing required fields: 'signature' and 'data'" }, status: :bad_request
    end

    signature = payload["signature"]
    data = payload["data"]

    signer = Signature::HmacSignature.new
    if signer.verify(data, signature)
      head :no_content
    else
      head :bad_request
    end
  rescue JSON::ParserError
    render json: { error: "Invalid JSON" }, status: :bad_request
  end
end
