class CryptoController < ApplicationController
  # Prevent Rails from wrapping the request body in a hash
  # This is a workaround to allow us to use the raw body in the controller instead of the usual params hash
  wrap_parameters false

  def encrypt
    payload = parse_json_payload
    return render_error(payload) if payload.is_a?(Hash) && payload.key?(:error)

    encryptor = Encryption::Base64Encryption.new
    encrypted_request = payload.transform_values { |value| encryptor.encrypt(value) }

    render json: encrypted_request
  end

  def decrypt
    payload = parse_json_payload
    return render_error(payload) if payload.is_a?(Hash) && payload.key?(:error)

    encryptor = Encryption::Base64Encryption.new
    decrypted_request = payload.transform_values { |value| encryptor.decrypt(value) }

    render json: decrypted_request
  end

  def sign
    payload = parse_json_payload
    return render_error(payload) if payload.is_a?(Hash) && payload.key?(:error)

    signer = Signature::HmacSignature.new
    signature = signer.sign(payload)

    render json: { signature: signature }
  end

  def verify
    payload = parse_json_payload
    return render_error(payload) if payload.is_a?(Hash) && payload.key?(:error)

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
  end

  private

  def parse_json_payload
    # Read body once and store it
    body = request.body.read
    return { error: "No payload provided", status: :bad_request } if body.blank?

    begin
      payload = JSON.parse(body)
      return { error: "Expected object, got #{payload.class.name}", status: :bad_request } unless payload.is_a?(Hash)

      payload
    rescue JSON::ParserError
      { error: "Invalid JSON", status: :bad_request }
    end
  end

  def render_error(error_hash)
    render json: { error: error_hash[:error] }, status: error_hash[:status]
  end
end
