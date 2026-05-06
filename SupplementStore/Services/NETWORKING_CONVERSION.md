# Axios to Swift URLSession Conversion

This document describes how all axios API calls from the React app have been converted to Swift networking using URLSession and async/await.

## Conversion Overview

| React (Axios) | Swift (URLSession) | Location |
|--------------|-------------------|----------|
| `axios.post('/auth/signin', data)` | `AuthService.signIn()` | `Services/Auth/AuthService.swift` |
| `axios.post('/auth/signup', data)` | `AuthService.signUp()` | `Services/Auth/AuthService.swift` |
| Generic axios calls | `APIService.request()` | `Services/API/APIService.swift` |

## React Axios Calls Found

### 1. Login (Login.jsx)
```javascript
let response = await axios.post(
    'http://power-fuelgym00.runasp.net/api/Auth/login',
    dataForm
);

if (response.data.message === 'success') {
    localStorage.setItem('userToken', response.data.token);
    setLogin(response.data.token);
}
```

### 2. Register (Register.jsx)
```javascript
let response = await axios.post(
    'http://power-fuelgym00.runasp.net/api/Auth/register',
    dataForm
);

if (response.data.message === 'success') {
    localStorage.setItem('userToken', response.data.token);
    setLogin(response.data.token);
}
```

## Swift Implementation

### AuthService.swift

**Sign In:**
```swift
func signIn(email: String, password: String) async throws -> AuthResponse {
    let body: [String: Any] = [
        "email": email,
        "password": password
    ]
    
    return try await apiService.post(
        endpoint: "auth/signin",
        body: body,
        requiresAuth: false
    )
}
```

**Sign Up:**
```swift
func signUp(name: String, email: String, password: String, phone: String) async throws -> AuthResponse {
    let body: [String: Any] = [
        "name": name,
        "email": email,
        "password": password,
        "phone": phone
    ]
    
    return try await apiService.post(
        endpoint: "auth/signup",
        body: body,
        requiresAuth: false
    )
}
```

### APIService.swift

Generic API service that handles all HTTP methods:

```swift
// GET request
func get<T: Decodable>(endpoint: String, requiresAuth: Bool = false) async throws -> T

// POST request
func post<T: Decodable>(
    endpoint: String,
    body: [String: Any]? = nil,
    requiresAuth: Bool = false
) async throws -> T

// PUT request
func put<T: Decodable>(
    endpoint: String,
    body: [String: Any]? = nil,
    requiresAuth: Bool = false
) async throws -> T

// DELETE request
func delete<T: Decodable>(endpoint: String, requiresAuth: Bool = false) async throws -> T
```

## Key Features

### 1. Error Handling
- Custom `NetworkError` enum for type-safe error handling
- HTTP status code handling (200-299 success, others error)
- JSON decoding/encoding error handling
- Network connectivity error handling

### 2. Authentication
- Automatic token injection for authenticated requests
- Token stored in UserDefaults (matches localStorage)
- `requiresAuth` parameter for protected endpoints

### 3. Request Configuration
- Timeout settings (30s request, 60s resource)
- JSON content type headers
- Accept headers
- Proper URL construction

### 4. Response Handling
- Automatic JSON decoding using Codable
- Type-safe response models
- Error response parsing

## Usage in ViewModels

### UserViewModel Integration

```swift
class UserViewModel: ObservableObject {
    private let authService = AuthService()
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.signIn(
                email: email,
                password: password
            )
            if response.message == "success" {
                await MainActor.run {
                    setLogin(response.token)
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
```

## Error Handling Example

```swift
do {
    let response = try await authService.signIn(
        email: email,
        password: password
    )
    // Success
} catch NetworkError.httpError(let statusCode, let message) {
    // Handle HTTP errors (400, 401, 500, etc.)
    print("HTTP Error \(statusCode): \(message ?? "Unknown")")
} catch NetworkError.networkError(let error) {
    // Handle network errors (no connection, timeout)
    print("Network error: \(error.localizedDescription)")
} catch {
    // Handle other errors
    print("Error: \(error.localizedDescription)")
}
```

## API Base URL

```
http://power-fuelgym00.runasp.net
```

## Request/Response Models

### AuthResponse
```swift
struct AuthResponse: Codable {
    let message: String      // "success"
    let token: String       // Authentication token
    let user: UserData?     // Optional user data
}
```

### APIErrorResponse
```swift
struct APIErrorResponse: Codable {
    let message: String?
    let errors: [String: [String]]?
}
```

## Comparison Table

| Feature | Axios (React) | URLSession (Swift) |
|---------|---------------|-------------------|
| Base URL | Hardcoded in each call | Configured in APIService |
| Headers | Set per request | Automatic + configurable |
| Body | JavaScript object | Dictionary `[String: Any]` |
| Response | `response.data` | Decoded type `T` |
| Errors | `catch (error)` | `catch NetworkError` |
| Async | `async/await` | `async/await` |
| Token | Manual header | Automatic via `requiresAuth` |
| Timeout | Default | 30s request, 60s resource |

## Benefits of Swift Implementation

1. **Type Safety**: Codable models ensure type-safe requests/responses
2. **Error Handling**: Custom error types for better error management
3. **Reusability**: Generic APIService for all endpoints
4. **Maintainability**: Centralized configuration
5. **Testing**: Easy to mock and test
6. **Performance**: Native URLSession is optimized

## Future Extensions

The networking layer is ready for additional endpoints:
- Products API
- Orders API
- User Profile API
- Cart API
- etc.

Simply add methods following the same pattern as AuthService.

