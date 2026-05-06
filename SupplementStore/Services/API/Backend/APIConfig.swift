import Foundation

/// Configuration for different environments
enum APIEnvironment {
    case development
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            // For simulator testing
            return "http://localhost:8001"
        case .production:
            // For device testing - update this to your Mac's IP
            return "http://192.168.1.11:8001"
        }
    }
    
    var apiKey: String? {
        switch self {
        case .development, .production:
            return "test-key"
        }
    }
    
    static var current: APIEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}

/// Helper to get current environment settings
extension APIEndpoints {
    static var currentBaseURL: String {
        return APIEnvironment.current.baseURL
    }
    
    static var currentAPIKey: String? {
        return APIEnvironment.current.apiKey
    }
}
