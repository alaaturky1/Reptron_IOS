# API Service Documentation

This document describes the Swift networking layer that replaces axios calls from the React app.

## Overview

The networking layer uses:
- **URLSession** for HTTP requests
- **async/await** for asynchronous operations
- **Codable** for JSON encoding/decoding
- **Error handling** with custom NetworkError types

## Architecture

### APIService
Generic API service class that handles all HTTP requests, matching axios functionality.

### AuthService
Authentication-specific service for sign in/sign up operations.

### NetworkError
Custom error types for better error handling.

## API Endpoints

### Authentication Endpoints

#### Sign In
**React:**
```javascript
axios.post('http://power-fuelgym00.runasp.net/api/Auth/login', {
    email: "user@example.com",
    password: "Password123"
})
```

**Swift:**
```swift
let authService = AuthService()
let response = try await authService.signIn(
    email: "user@example.com",
    password: "Password123"
)
// response.token contains the authentication token
```

#### Sign Up
**React:**
```javascript
axios.post('http://power-fuelgym00.runasp.net/api/Auth/register', {
    name: "John Doe",
    email: "user@example.com",
    password: "Password123",
    phone: "01234567890"
})
```

**Swift:**
```swift
let authService = AuthService()
let response = try await authService.signUp(
    name: "John Doe",
    email: "user@example.com",
    password: "Password123",
    phone: "01234567890"
)
// response.token contains the authentication token
```

## Usage Examples

### Basic Request
```swift
let apiService = APIService.shared

// GET request
let data: MyResponse = try await apiService.get(endpoint: "products")

// POST request
let body: [String: Any] = ["key": "value"]
let response: MyResponse = try await apiService.post(
    endpoint: "products",
    body: body
)
```

### With Authentication
```swift
// Authenticated GET request
let userData: UserResponse = try await apiService.get(
    endpoint: "user/profile",
    requiresAuth: true
)

// Authenticated POST request
let order: OrderResponse = try await apiService.post(
    endpoint: "orders",
    body: orderData,
    requiresAuth: true
)
```

### Error Handling
```swift
do {
    let response = try await authService.signIn(
        email: email,
        password: password
    )
    // Handle success
} catch NetworkError.httpError(let statusCode, let message) {
    // Handle HTTP error (400, 401, 500, etc.)
    print("Error \(statusCode): \(message ?? "Unknown error")")
} catch NetworkError.networkError(let error) {
    // Handle network error (no connection, timeout, etc.)
    print("Network error: \(error.localizedDescription)")
} catch {
    // Handle other errors
    print("Error: \(error.localizedDescription)")
}
```

## Request/Response Models

### SignInRequest
```swift
struct SignInRequest: Codable {
    let email: String
    let password: String
}
```

### SignUpRequest
```swift
struct SignUpRequest: Codable {
    let name: String
    let email: String
    let password: String
    let phone: String
}
```

### AuthResponse
```swift
struct AuthResponse: Codable {
    let message: String      // "success"
    let token: String       // Authentication token
    let user: UserData?     // Optional user data
}
```

## Error Types

### NetworkError Cases
- `.invalidURL` - Invalid URL format
- `.invalidResponse` - Invalid HTTP response
- `.httpError(statusCode:message:)` - HTTP error (4xx, 5xx)
- `.decodingError(Error)` - JSON decoding failed
- `.encodingError(Error)` - JSON encoding failed
- `.noData` - No data in response
- `.unauthorized` - Missing or invalid token
- `.networkError(Error)` - Network connection error

## Configuration

### Base URL
```
http://power-fuelgym00.runasp.net
```

### Timeout Settings
- Request timeout: 30 seconds
- Resource timeout: 60 seconds

### Headers
- `Content-Type: application/json`
- `Accept: application/json`
- `token: <auth_token>` (when requiresAuth = true)

## Comparison with Axios

| Axios | Swift URLSession |
|-------|------------------|
| `axios.post(url, data)` | `apiService.post(endpoint:body:)` |
| `axios.get(url)` | `apiService.get(endpoint:)` |
| `axios.put(url, data)` | `apiService.put(endpoint:body:)` |
| `axios.delete(url)` | `apiService.delete(endpoint:)` |
| `response.data` | Decoded response object |
| `response.status` | HTTP status code |
| `catch (error)` | `catch NetworkError` |

## Future Extensions

The API service is designed to be easily extended for additional endpoints:
- Products API
- Orders API
- User Profile API
- etc.

Simply add methods to the appropriate service class following the same pattern.

