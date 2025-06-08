require 'rails_helper'

describe Encryption::Base64Encryption do
  let(:encryption_service) { described_class.new }

  describe '#encrypt' do
    it 'encrypts a string' do
      expect(encryption_service.encrypt('hello')).to eq(Base64.strict_encode64('hello'))
    end

    it 'encrypts a number' do
      expect(encryption_service.encrypt(123)).to eq(Base64.strict_encode64('123'))
    end

    it 'encrypts a hash as JSON' do
      hash = { name: 'George Abitbol', age: "57", contact: { email: "classe@americaine.com", phone: "123-456-789" } }
      expect(encryption_service.encrypt(hash)).to eq(Base64.strict_encode64(hash.to_json))
    end

    it 'encrypts an array as JSON' do
      arr = [ 1, 'two', { three: 3 } ]
      expect(encryption_service.encrypt(arr)).to eq(Base64.strict_encode64(arr.to_json))
    end

    it 'raises error for unsupported type' do
      expect { encryption_service.encrypt(nil) }.to raise_error(ArgumentError)
    end
  end

  describe '#decrypt' do
    it 'decrypts a string' do
      encrypted = encryption_service.encrypt('hello')
      expect(encryption_service.decrypt(encrypted)).to eq('hello')
    end

    it 'decrypts a number' do
      encrypted = encryption_service.encrypt(123)
      expect(encryption_service.decrypt(encrypted)).to eq(123)
    end

    it 'decrypts a hash as JSON' do
      hash = { name: 'George Abitbol', age: "57", contact: { email: "classe@americaine.com", phone: "123-456-789" } }
      encrypted = encryption_service.encrypt(hash)
      expect(encryption_service.decrypt(encrypted)).to eq(JSON.parse(hash.to_json))
    end

    it 'decrypts an array as JSON' do
      arr = [ 1, 'two', { three: 3 } ]
      encrypted = encryption_service.encrypt(arr)
      expect(encryption_service.decrypt(encrypted)).to eq(JSON.parse(arr.to_json))
    end

    it 'returns value as is if not valid Base64' do
      expect(encryption_service.decrypt('not_base64')).to eq('not_base64')
    end

    it 'returns non-string values as is' do
      expect(encryption_service.decrypt(123)).to eq(123)
      expect(encryption_service.decrypt(nil)).to eq(nil)
      expect(encryption_service.decrypt({ key: 'value' })).to eq({ key: 'value' })
      expect(encryption_service.decrypt([ 1, 2, 3 ])).to eq([ 1, 2, 3 ])
    end
  end
end
