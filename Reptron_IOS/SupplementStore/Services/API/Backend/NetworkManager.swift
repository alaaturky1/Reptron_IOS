import Foundation

final class NetworkManager {
    static let shared = NetworkManager()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let tokenKey = "userToken"

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }

    func clearToken() {
        token = nil
    }

    @discardableResult
    private func request<T: Decodable, Body: Encodable>(
        _ endpoint: String,
        method: String,
        body: Body? = nil,
        requiresAuth: Bool = false,
        responseType: T.Type = T.self
    ) async throws -> T {
        guard let url = URL(string: APIEndpoints.baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            guard let token, !token.isEmpty else { throw APIError.unauthorized }
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            do {
                urlRequest.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.encodingError(error)
            }
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let payload = try? decoder.decode(APIErrorPayload.self, from: data)
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: payload?.bestMessage)
            }

            if T.self == EmptyResponse.self {
                return try decoder.decode(T.self, from: Data("{}".utf8))
            }

            guard !data.isEmpty else {
                throw APIError.emptyResponse
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Auth
extension NetworkManager {
    func login(_ requestBody: LoginRequest) async throws -> AuthTokenResponse {
        let response: AuthTokenResponse = try await request(
            APIEndpoints.Auth.login,
            method: "POST",
            body: requestBody,
            requiresAuth: false
        )

        if let token = response.token, !token.isEmpty {
            self.token = token
        }

        return response
    }

    func register(_ requestBody: RegisterRequest) async throws -> AuthTokenResponse {
        let response: AuthTokenResponse = try await request(
            APIEndpoints.Auth.register,
            method: "POST",
            body: requestBody,
            requiresAuth: false
        )

        if let token = response.token, !token.isEmpty {
            self.token = token
        }

        return response
    }
}

// MARK: - Products
extension NetworkManager {
    func getProducts() async throws -> [JSONValue] {
        try await request(APIEndpoints.Products.all, method: "GET", requiresAuth: false)
    }

    func getProduct(id: Int) async throws -> JSONValue {
        try await request(APIEndpoints.Products.byId(id), method: "GET", requiresAuth: false)
    }

    func getBestSellers() async throws -> [JSONValue] {
        try await request(APIEndpoints.Products.bestSellers, method: "GET", requiresAuth: false)
    }
}

// MARK: - Cart
extension NetworkManager {
    func getCart() async throws -> JSONValue {
        try await request(APIEndpoints.Cart.current, method: "GET", requiresAuth: true)
    }

    func addCartItem(_ requestBody: AddToCartRequest) async throws -> JSONValue {
        try await request(APIEndpoints.Cart.items, method: "POST", body: requestBody, requiresAuth: true)
    }

    func updateCartItem(cartItemId: Int, quantity: Int) async throws -> JSONValue {
        let body = QuantityUpdateRequest(quantity: quantity)
        return try await request(APIEndpoints.Cart.item(cartItemId), method: "PUT", body: body, requiresAuth: true)
    }

    func deleteCartItem(cartItemId: Int) async throws {
        let _: EmptyResponse = try await request(APIEndpoints.Cart.item(cartItemId), method: "DELETE", requiresAuth: true)
    }
}

// MARK: - Orders
extension NetworkManager {
    func createOrder(_ requestBody: CreateOrderRequest) async throws -> JSONValue {
        try await request(APIEndpoints.Orders.create, method: "POST", body: requestBody, requiresAuth: true)
    }

    func getOrders() async throws -> [JSONValue] {
        try await request(APIEndpoints.Orders.all, method: "GET", requiresAuth: true)
    }

    func getOrder(orderId: Int) async throws -> JSONValue {
        try await request(APIEndpoints.Orders.byId(orderId), method: "GET", requiresAuth: true)
    }
}

// MARK: - Reviews
extension NetworkManager {
    func getProductReviews(productId: Int) async throws -> [JSONValue] {
        try await request(APIEndpoints.Reviews.product(productId), method: "GET", requiresAuth: false)
    }

    func createProductReview(productId: Int, requestBody: CreateReviewRequest) async throws -> JSONValue {
        try await request(APIEndpoints.Reviews.product(productId), method: "POST", body: requestBody, requiresAuth: true)
    }

    func getEquipmentReviews(equipmentId: Int) async throws -> [JSONValue] {
        try await request(APIEndpoints.Reviews.equipment(equipmentId), method: "GET", requiresAuth: false)
    }

    func createEquipmentReview(equipmentId: Int, requestBody: CreateReviewRequest) async throws -> JSONValue {
        try await request(APIEndpoints.Reviews.equipment(equipmentId), method: "POST", body: requestBody, requiresAuth: true)
    }
}

// MARK: - Coaches
extension NetworkManager {
    func getCoaches() async throws -> [JSONValue] {
        try await request(APIEndpoints.Coaches.all, method: "GET", requiresAuth: false)
    }

    func getCoach(id: Int) async throws -> JSONValue {
        try await request(APIEndpoints.Coaches.byId(id), method: "GET", requiresAuth: false)
    }

    func getCoachAvailability(id: Int) async throws -> JSONValue {
        try await request(APIEndpoints.Coaches.availability(id), method: "GET", requiresAuth: false)
    }

    func createCoachBooking(id: Int, requestBody: CreateBookingRequest) async throws -> JSONValue {
        try await request(APIEndpoints.Coaches.bookings(id), method: "POST", body: requestBody, requiresAuth: true)
    }
}

// MARK: - Equipment
extension NetworkManager {
    func getEquipments() async throws -> [JSONValue] {
        try await request(APIEndpoints.Equipment.all, method: "GET", requiresAuth: false)
    }

    func getEquipment(id: Int) async throws -> JSONValue {
        try await request(APIEndpoints.Equipment.byId(id), method: "GET", requiresAuth: false)
    }
}

// MARK: - Categories
extension NetworkManager {
    func getProductCategories() async throws -> [JSONValue] {
        try await request(APIEndpoints.Categories.products, method: "GET", requiresAuth: false)
    }

    func getEquipmentCategories() async throws -> [JSONValue] {
        try await request(APIEndpoints.Categories.equipment, method: "GET", requiresAuth: false)
    }
}

// MARK: - Supporting Models
struct AuthTokenResponse: Decodable {
    let token: String?
}

private struct QuantityUpdateRequest: Encodable {
    let quantity: Int
}

private struct EmptyResponse: Decodable {}

enum JSONValue: Decodable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else {
            throw DecodingError.typeMismatch(
                JSONValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON value")
            )
        }
    }
}
