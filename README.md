# Riot Take Home Challenge

A Ruby on Rails API application that provides cryptographic operations including encryption, decryption, signing, and verification of JSON payloads.

This application was developed as part of a technical challenge for [Riot](https://tryriot.com/fr/).

## Features

- **Encryption**: Encrypt JSON payloads using Base64 encoding
- **Decryption**: Decrypt Base64-encoded payloads back to original format
- **Signing**: Generate HMAC signatures for JSON payloads
- **Verification**: Verify HMAC signatures for data integrity
- **Modular Design**: Easily swappable encryption and signature algorithms

## Requirements

- Ruby 3.4.4
- Rails 8.0.2

## Installation

1. Clone the repository:

   ```bash
   git clone git@github.com:DorianGC-G/take-home-riot.git
   cd take-home-riot
   ```

2. Install dependencies:

   ```bash
   bundle install
   ```

3. Start the server:
   ```bash
   rails server
   ```

The API will be available at `http://localhost:3000`

## API Endpoints

### 1. Encrypt (`POST /encrypt`)

Encrypts all properties at depth 1 of a JSON payload using Base64 encoding.

**Request:**

```json
{
  "name": "John Doe",
  "age": 30,
  "contact": {
    "email": "john@example.com",
    "phone": "123-456-7890"
  }
}
```

**Response:**

```json
{
  "name": "Sm9obiBEb2U=",
  "age": "MzA=",
  "contact": "eyJlbWFpbCI6ImpvaG5AZXhhbXBsZS5jb20iLCJwaG9uZSI6IjEyMy00NTYtNzg5MCJ9"
}
```

### 2. Decrypt (`POST /decrypt`)

Decrypts Base64-encoded values back to their original format. Non-encrypted values remain unchanged.

**Request:**

```json
{
  "name": "Sm9obiBEb2U=",
  "age": "MzA=",
  "contact": "eyJlbWFpbCI6ImpvaG5AZXhhbXBsZS5jb20iLCJwaG9uZSI6IjEyMy00NTYtNzg5MCJ9"
}
```

**Response:**

```json
{
  "name": "John Doe",
  "age": 30,
  "contact": {
    "email": "john@example.com",
    "phone": "123-456-7890"
  }
}
```

### 3. Sign (`POST /sign`)

Generates an HMAC signature for a JSON payload. The signature is computed based on the value of the JSON payload, making it order-independent.

**Request:**

```json
{
  "message": "Hello World",
  "timestamp": 1616161616
}
```

**Response:**

```json
{
  "signature": "a1b2c3d4e5f6g7h8i9j0..."
}
```

### 4. Verify (`POST /verify`)

Verifies an HMAC signature against the provided data.

**Request:**

```json
{
  "signature": "a1b2c3d4e5f6g7h8i9j0...",
  "data": {
    "message": "Hello World",
    "timestamp": 1616161616
  }
}
```

**Response:**

- `204 No Content` - Signature is valid
- `400 Bad Request` - Signature is invalid

## Architecture

The application follows a modular design with strategy patterns for easy algorithm swapping:

```
app/
├── controllers/
│   └── crypto_controller.rb      # Main API controller
├── services/
│   ├── encryption/
│   │   ├── encryption_strategy.rb # Abstract encryption interface
│   │   └── base64_encryption.rb   # Base64 implementation
│   └── signature/
│       ├── signature_strategy.rb  # Abstract signature interface
│       └── hmac_signature.rb      # HMAC implementation
```

### Key Design Principles

1. **Strategy Pattern**: Both encryption and signature services use the strategy pattern, making it easy to swap algorithms without changing the core logic.

2. **Consistency**: The encrypt/decrypt operations are perfectly reversible, and sign/verify operations are consistent.

3. **Error Handling**: Comprehensive error handling for invalid JSON, missing fields, and malformed requests.

4. **Order Independence**: The HMAC signature algorithm is designed to be independent of JSON property order.

## Testing

Run the test suite with:

```bash
bundle exec rspec
```

Running this command will generate a coverage report under /coverage at the applications's root.
You can open the index.html file in a browser to get more details.

## Development

### Code Quality

The project uses:

- **RuboCop** for code style enforcement
- **Brakeman** for security vulnerability scanning
- **RSpec** for testing
- **SimpleCov** for test coverage

Run linting:

```bash
bundle exec rubocop
```

Run security scan:

```bash
bundle exec brakeman
```

### Adding New Algorithms

To add a new encryption algorithm:

1. Create a new class in `app/services/encryption/` that implements the `EncryptionStrategy` interface
2. Update the controller to use the new encryption class

To add a new signature algorithm:

1. Create a new class in `app/services/signature/` that implements the `SignatureStrategy` interface
2. Update the controller to use the new signature class
