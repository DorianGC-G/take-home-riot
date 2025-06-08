require 'rails_helper'

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
end
