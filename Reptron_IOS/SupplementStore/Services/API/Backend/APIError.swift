import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case encodingError(Error)
    case unauthorized
    case serverError(statusCode: Int, message: String?)
    case networkError(Error)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid server response."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized request."
        case .serverError(let statusCode, let message):
            return message ?? "Server error (\(statusCode))."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .emptyResponse:
            return "Server returned an empty response."
        }
    }
}

struct APIErrorPayload: Decodable {
    let message: String?
    let title: String?
    let errors: [String: [String]]?

    var bestMessage: String? {
        if let message, !message.isEmpty { return message }
        if let title, !title.isEmpty { return title }
        if let errors {
            return errors.values.flatMap { $0 }.joined(separator: ", ")
        }
        return nil
    }
}
