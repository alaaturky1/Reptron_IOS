import Foundation

/// API base - production server
enum APIEndpoints {
    static let baseURL = "http://power-fuelgym00.runasp.net"

    /// Builds an absolute URL from a path like `/api/Products` (single source of truth for the host).
    static func url(path: String) -> URL? {
        let trimmedBase = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let p = path.hasPrefix("/") ? path : "/" + path
        return URL(string: "\(trimmedBase)\(p)")
    }

    enum AI {
        private static let prefix = "/api/FitnessCoach"
        private static let legacyPrefix = ""

        static let startSession = "\(prefix)/start-session"
        static let analyzeFrame = "\(prefix)/analyze-frame"
        static let endSession = "\(prefix)/end-session"
        static func sessionSummary(_ sessionId: String) -> String {
            "\(prefix)/session-summary/\(sessionId)"
        }
        static let legacyStartSession = "\(legacyPrefix)/start-session"
        static let legacyAnalyzeFrame = "\(legacyPrefix)/analyze-frame"
        static let legacyEndSession = "\(legacyPrefix)/end-session"
        static func legacySessionSummary(_ sessionId: String) -> String {
            "\(legacyPrefix)/session-summary/\(sessionId)"
        }

    }

    enum Auth {
        static let login = "/api/Auth/login"
        static let register = "/api/Auth/register"
        /// Not in published Swagger yet; server should expose `POST` with `currentPassword` + `newPassword` (JWT).
        static let changePassword = "/api/Auth/change-password"
    }

    enum Products {
        static let all = "/api/Products"
        static func byId(_ id: Int) -> String { "/api/Products/\(id)" }
        static let bestSellers = "/api/Products/best-sellers"
    }

    enum Cart {
        static let current = "/api/Cart"
        static let items = "/api/Cart/items"
        static func item(_ cartItemId: Int) -> String { "/api/Cart/items/\(cartItemId)" }
    }

    enum Orders {
        static let create = "/api/Orders"
        static let all = "/api/Orders"
        static func byId(_ orderId: Int) -> String { "/api/Orders/\(orderId)" }
    }

    enum Reviews {
        static func product(_ productId: Int) -> String { "/api/Reviews/products/\(productId)" }
        static func equipment(_ equipmentId: Int) -> String { "/api/Reviews/equipment/\(equipmentId)" }
    }

    enum Coaches {
        static let all = "/api/Coaches"
        static func byId(_ id: Int) -> String { "/api/Coaches/\(id)" }
        static func availability(_ id: Int) -> String { "/api/Coaches/\(id)/availability" }
        static func bookings(_ id: Int) -> String { "/api/Coaches/\(id)/bookings" }
    }

    enum Equipment {
        static let all = "/api/Equipments"
        static func byId(_ id: Int) -> String { "/api/Equipments/\(id)" }
    }

    enum Categories {
        static let products = "/api/Categories/products"
        static let equipment = "/api/Categories/equipment"
    }
}
