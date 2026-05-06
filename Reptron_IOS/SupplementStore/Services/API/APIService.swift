//
//  APIService.swift
//  SupplementStore
//
//  Created on [Date]
//
//  Generic API service using URLSession and async/await
//  Matches axios functionality from React app
//

import Foundation

class APIService {
    static let shared = APIService()
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Generic Request Method (matches axios pattern)
    /// Generic request method that handles all HTTP methods
    /// - Parameters:
    ///   - endpoint: API endpoint (e.g., "auth/signin")
    ///   - method: HTTP method (GET, POST, PUT, DELETE)
    ///   - body: Request body as dictionary
    ///   - requiresAuth: Whether to include authentication token
    /// - Returns: Decoded response of type T
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: [String: Any]? = nil,
        requiresAuth: Bool = false,
        treatEmptyResponseAsEmptyJSONObject: Bool = false
    ) async throws -> T {
        // Build URL safely (avoid accidental `//` when endpoint already starts with `/`)
        let normalizedEndpoint = endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let normalizedBaseURL = APIEndpoints.baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(normalizedBaseURL)/\(normalizedEndpoint)") else {
            throw NetworkError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authentication token if required
        if requiresAuth {
            if let token = UserDefaults.standard.string(forKey: "userToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw NetworkError.unauthorized
            }
        }
        
        // Add request body if provided
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        // Perform request
        do {
            let (data, response) = try await session.data(for: request)
            
            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // Handle HTTP status codes
            guard (200...299).contains(httpResponse.statusCode) else {
                // Try to decode error response
                let errorMessage = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
                throw NetworkError.httpError(
                    statusCode: httpResponse.statusCode,
                    message: errorMessage?.errorMessage
                )
            }
            
            // Decode response
            do {
                let decodeData: Data
                if treatEmptyResponseAsEmptyJSONObject, data.isEmpty {
                    decodeData = Data("{}".utf8)
                } else {
                    decodeData = data
                }
                return try JSONDecoder().decode(T.self, from: decodeData)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    // MARK: - Convenience Methods (matching axios methods)
    
    /// GET request
    func get<T: Decodable>(endpoint: String, requiresAuth: Bool = false) async throws -> T {
        return try await request(endpoint: endpoint, method: .GET, requiresAuth: requiresAuth)
    }
    
    /// POST request
    func post<T: Decodable>(
        endpoint: String,
        body: [String: Any]? = nil,
        requiresAuth: Bool = false,
        treatEmptyResponseAsEmptyJSONObject: Bool = false
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: .POST,
            body: body,
            requiresAuth: requiresAuth,
            treatEmptyResponseAsEmptyJSONObject: treatEmptyResponseAsEmptyJSONObject
        )
    }
    
    /// PUT request
    func put<T: Decodable>(
        endpoint: String,
        body: [String: Any]? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        return try await request(endpoint: endpoint, method: .PUT, body: body, requiresAuth: requiresAuth)
    }
    
    /// DELETE request
    func delete<T: Decodable>(endpoint: String, requiresAuth: Bool = false) async throws -> T {
        return try await request(endpoint: endpoint, method: .DELETE, requiresAuth: requiresAuth)
    }
}

// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}
