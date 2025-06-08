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

  it 'returns error for empty payload' do
    post url, params: '', headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
    json = JSON.parse(response.body)
    expect(json['error']).to eq('No payload provided')
  end

  it 'returns error for invalid JSON' do
    post url, params: '{invalid_json:', headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
    json = JSON.parse(response.body)
    expect(json['error']).to eq('Invalid JSON')
  end

  it 'returns error for non-hash payload' do
    post url, params: '[1, 2, 3]', headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
    json = JSON.parse(response.body)
    expect(json['error']).to eq('Invalid request format')
  end
end
