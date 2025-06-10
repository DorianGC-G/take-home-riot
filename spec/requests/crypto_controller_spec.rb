require 'rails_helper'

# Shared examples for common error handling tests
shared_examples "API error handling" do |endpoint|
  let(:url) { "/#{endpoint}" }

  it "returns 400 for empty body" do
    post url, params: "", headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
    json = JSON.parse(response.body)
    expect(json['error']).to eq('No payload provided')
  end

  it "returns 400 for invalid JSON" do
    post url, params: '{invalid_json:', headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
    json = JSON.parse(response.body)
    expect(json['error']).to eq('Invalid JSON')
  end

  it "returns 400 for non-object payload (array)" do
    post url, params: [ 1, 2, 3 ].to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
    json = JSON.parse(response.body)
    expect(json['error']).to eq('Expected object, got Array')
  end

  it "returns 400 for non-object payload (string)" do
    post url, params: '"just a string"'.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
    json = JSON.parse(response.body)
    expect(json['error']).to eq('Expected object, got String')
  end
end

describe 'POST /encrypt', type: :request do
  let(:url) { '/encrypt' }

  it 'encrypts all top-level properties' do
    payload = {
      "name": "George Abitbol",
      "country": "Texas",
      "info": {
          "phone": "123-456-789",
          "favourite_catchphrase": "Sur mon front y'a pas marqué radio-réveil"
      }
    }
    post url, params: payload.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json['name']).to eq(Base64.strict_encode64('George Abitbol'))
    expect(json['country']).to eq(Base64.strict_encode64('Texas'))
    expect(json['info']).to eq(Base64.strict_encode64(payload[:info].to_json))
  end

  it 'returns error for invalid JSON' do
    post url, params: '{invalid_json:', headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
    json = JSON.parse(response.body)
    expect(json['error']).to eq('Invalid JSON')
  end

  # Include shared error handling tests
  include_examples "API error handling", "encrypt"
end

describe 'POST /decrypt', type: :request do
  let(:url) { '/decrypt' }

  it 'decrypts all top-level properties' do
    # Create encrypted payload
    original_payload = {
      "name": "George Abitbol",
      "country": "Texas",
      "info": {
          "phone": "123-456-789",
          "favourite_catchphrase": "Sur mon front y'a pas marqué radio-réveil"
      }
    }

    encrypted_payload = {
      "name": Base64.strict_encode64('George Abitbol'),
      "country": Base64.strict_encode64('Texas'),
      "info": Base64.strict_encode64(original_payload[:info].to_json)
    }

    post url, params: encrypted_payload.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)

    expect(json['name']).to eq('George Abitbol')
    expect(json['country']).to eq('Texas')
    expect(json['info']).to eq(JSON.parse(original_payload[:info].to_json))
  end

  it 'leaves unencrypted properties unchanged' do
    payload = {
      "name": Base64.strict_encode64('George Abitbol'),
      "birth_date": "1998-11-19"
    }

    post url, params: payload.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)

    expect(json['name']).to eq('George Abitbol')
    expect(json['birth_date']).to eq('1998-11-19')
  end

  it 'handles mixed encrypted and non-string values' do
    payload = {
      "name": Base64.strict_encode64('George Abitbol'),
      "age": 30,
      "is_active": true,
      "details": { "restaurant": "Mexican food" },
      "tags": [ 1, 2, 3 ]
    }

    post url, params: payload.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)

    expect(json['name']).to eq('George Abitbol')
    expect(json['age']).to eq(30)
    expect(json['is_active']).to eq(true)
    expect(json['details']).to eq({ "restaurant" => "Mexican food" })
    expect(json['tags']).to eq([ 1, 2, 3 ])
  end

  it 'returns error for invalid JSON' do
    post url, params: '{invalid_json:', headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
    json = JSON.parse(response.body)
    expect(json['error']).to eq('Invalid JSON')
  end

  # Include shared error handling tests
  include_examples "API error handling", "decrypt"
end

describe 'POST /sign', type: :request do
  let(:url) { '/sign' }
  let(:signer) { Signature::HmacSignature.new }

  it 'returns a signature for the payload' do
    payload = {
      "message": "Hello World",
      "timestamp": 1616161616
    }

    post url, params: payload.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)

    expect(json).to have_key('signature')
    expect(json['signature']).not_to be_empty
    expect(json['signature']).to eq(signer.sign(payload))
  end

  it 'generates the same signature regardless of key order' do
    payload1 = {
      "message": "Hello World",
      "timestamp": 1616161616
    }

    payload2 = {
      "timestamp": 1616161616,
      "message": "Hello World"
    }

    post url, params: payload1.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    signature1 = JSON.parse(response.body)['signature']

    post url, params: payload2.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    signature2 = JSON.parse(response.body)['signature']

    expect(signature1).to eq(signature2)
  end

  it 'returns error for invalid JSON' do
    post url, params: '{invalid_json:', headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
    json = JSON.parse(response.body)
    expect(json['error']).to eq('Invalid JSON')
  end

  # Include shared error handling tests
  include_examples "API error handling", "sign"
end

describe 'POST /verify', type: :request do
  let(:url) { '/verify' }
  let(:signer) { Signature::HmacSignature.new }

  it 'returns 204 for valid signature' do
    data = {
      "message": "Hello World",
      "timestamp": 1616161616
    }

    signature = signer.sign(data)
    payload = {
      "signature": signature,
      "data": data
    }

    post url, params: payload.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:no_content)
  end

  it 'returns 204 for valid signature with different key order' do
    data1 = {
      "message": "Hello World",
      "timestamp": 1616161616
    }

    data2 = {
      "timestamp": 1616161616,
      "message": "Hello World"
    }

    signature = signer.sign(data1)
    payload = {
      "signature": signature,
      "data": data2
    }

    post url, params: payload.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:no_content)
  end

  it 'returns 400 for invalid signature' do
    data = {
      "message": "Hello World",
      "timestamp": 1616161616
    }

    tampered_data = {
      "message": "Goodbye World",
      "timestamp": 1616161616
    }

    signature = signer.sign(data)
    payload = {
      "signature": signature,
      "data": tampered_data
    }

    post url, params: payload.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
  end

  it 'returns 400 for missing required fields' do
    payload = {
      "signature": "some_signature"
      # missing data field
    }

    post url, params: payload.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)

    payload = {
      "data": { "message": "Hello World" }
      # missing signature field
    }

    post url, params: payload.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
  end

  it 'returns error for invalid JSON' do
    post url, params: '{invalid_json:', headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
    json = JSON.parse(response.body)
    expect(json['error']).to eq('Invalid JSON')
  end

  # Include shared error handling tests
  include_examples "API error handling", "verify"
end
