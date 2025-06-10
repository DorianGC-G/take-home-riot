require 'rails_helper'

describe Signature::HmacSignature do
  let(:signature_service) { described_class.new('test_secret') }

  describe '#sign' do
    it 'generates a signature for a string' do
      expect(signature_service.sign('hello')).to be_a(String)
      expect(signature_service.sign('hello')).not_to be_empty
    end

    it 'generates a signature for a hash' do
      hash = { name: 'George Abitbol', age: 57 }
      expect(signature_service.sign(hash)).to be_a(String)
      expect(signature_service.sign(hash)).not_to be_empty
    end

    it 'generates a signature for an array' do
      arr = [ 1, 'two', { three: 3 } ]
      expect(signature_service.sign(arr)).to be_a(String)
      expect(signature_service.sign(arr)).not_to be_empty
    end

    it 'generates the same signature regardless of hash key order' do
      hash1 = { name: 'George Abitbol', age: 57 }
      hash2 = { age: 57, name: 'George Abitbol' }

      expect(signature_service.sign(hash1)).to eq(signature_service.sign(hash2))
    end

    it 'generates the same signature for nested hashes regardless of key order' do
      hash1 = {
        user: { name: 'George Abitbol', age: 57 },
        timestamp: 1616161616
      }

      hash2 = {
        timestamp: 1616161616,
        user: { age: 57, name: 'George Abitbol' }
      }

      expect(signature_service.sign(hash1)).to eq(signature_service.sign(hash2))
    end
  end

  describe '#verify' do
    it 'verifies a valid signature' do
      data = { message: 'Hello World', timestamp: 1616161616 }
      signature = signature_service.sign(data)

      expect(signature_service.verify(data, signature)).to be true
    end

    it 'rejects an invalid signature' do
      data = { message: 'Hello World', timestamp: 1616161616 }
      signature = signature_service.sign(data)

      tampered_data = { message: 'Goodbye World', timestamp: 1616161616 }
      expect(signature_service.verify(tampered_data, signature)).to be false
    end

    it 'rejects a tampered signature' do
      data = { message: 'Hello World', timestamp: 1616161616 }
      signature = signature_service.sign(data)
      tampered_signature = signature.reverse

      expect(signature_service.verify(data, tampered_signature)).to be false
    end
  end
end
