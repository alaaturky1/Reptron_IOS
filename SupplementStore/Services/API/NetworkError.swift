//
//  NetworkError.swift
//  SupplementStore
//
//  Created on [Date]
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case encodingError(Error)
    case noData
    case unauthorized
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            return message ?? "HTTP Error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .noData:
            return "No data received from server"
        case .unauthorized:
            return "Unauthorized access"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// API Error Response structure (matching common API error formats)
struct APIErrorResponse: Codable {
    let message: String?
    let errors: [String: [String]]?
    
    var errorMessage: String {
        if let message = message {
            return message
        }
        if let errors = errors {
            return errors.values.flatMap { $0 }.joined(separator: ", ")
        }
        return "An error occurred"
    }
}

