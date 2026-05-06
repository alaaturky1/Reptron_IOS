//
//  AuthService.swift
//  SupplementStore
//
//  Created on [Date]
//
//  Authentication service matching React axios calls
//  React: axios.post('http://localhost:3000/auth/signin', dataForm)
//  React: axios.post('http://localhost:3000/auth/signup', dataForm)
//

import Foundation

// MARK: - Request Models

struct SignInRequest: Codable {
    let email: String
    let password: String
}

struct SignUpRequest: Codable {
    let name: String
    let email: String
    let password: String
    let phone: String
}

// MARK: - Response Models

struct AuthResponse: Decodable {
    let message: String?
    let token: String?
    let user: UserData?

    struct UserData: Decodable {
        let name: String?
        let userName: String?
        let email: String?
        let phone: String?
        let phoneNumber: String?
        private let idInt: Int?
        private let userIdInt: Int?
        private let idString: String?

        enum CodingKeys: String, CodingKey {
            case name, userName, email, phone, phoneNumber, id, userId
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            name = try c.decodeIfPresent(String.self, forKey: .name)
            userName = try c.decodeIfPresent(String.self, forKey: .userName)
            email = try c.decodeIfPresent(String.self, forKey: .email)
            phone = try c.decodeIfPresent(String.self, forKey: .phone)
            phoneNumber = try c.decodeIfPresent(String.self, forKey: .phoneNumber)
            idInt = try c.decodeIfPresent(Int.self, forKey: .id)
            userIdInt = try c.decodeIfPresent(Int.self, forKey: .userId)
            if let s = try? c.decodeIfPresent(String.self, forKey: .id), !s.isEmpty {
                idString = s
            } else {
                idString = nil
            }
        }

        var resolvedDisplayName: String? {
            [name, userName].compactMap { $0 }.first { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        }

        var resolvedPhone: String? {
            let p = phone ?? phoneNumber
            return p?.isEmpty == true ? nil : p
        }

        var resolvedIdString: String? {
            if let idInt { return String(idInt) }
            if let userIdInt { return String(userIdInt) }
            if let idString, !idString.isEmpty { return idString }
            return nil
        }
    }
}

extension AuthResponse {
    static func resolveUserId(user: UserData?, token: String) -> String {
        if let s = user?.resolvedIdString, !s.isEmpty { return s }
        if let j = JWTUserIdExtractor.userId(from: token) { return j }
        return "user_\(abs(token.hashValue))"
    }
}

/// Flexible shape for GET profile endpoints (backend may vary).
struct RemoteUserProfileDTO: Decodable {
    let email: String?
    let userName: String?
    let name: String?
    let fullName: String?
    let phoneNumber: String?
    let phone: String?
    private let idInt: Int?
    private let userIdInt: Int?

    enum CodingKeys: String, CodingKey {
        case email, userName, name, fullName, phoneNumber, phone, id, userId
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        email = try c.decodeIfPresent(String.self, forKey: .email)
        userName = try c.decodeIfPresent(String.self, forKey: .userName)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        fullName = try c.decodeIfPresent(String.self, forKey: .fullName)
        phoneNumber = try c.decodeIfPresent(String.self, forKey: .phoneNumber)
        phone = try c.decodeIfPresent(String.self, forKey: .phone)
        idInt = try c.decodeIfPresent(Int.self, forKey: .id)
        userIdInt = try c.decodeIfPresent(Int.self, forKey: .userId)
    }

    var resolvedUserIdString: String? {
        if let idInt { return String(idInt) }
        if let userIdInt { return String(userIdInt) }
        return nil
    }

    var resolvedName: String? {
        [name, fullName, userName].compactMap { $0 }.first { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var resolvedEmail: String? { email }

    var resolvedPhone: String? {
        let p = phone ?? phoneNumber
        return p?.isEmpty == true ? nil : p
    }
}

// MARK: - Auth Service

final class AuthService {
    static let shared = AuthService()

    private let apiService = APIService.shared

    // MARK: - Sign In
    /// Sign in user (matches React: axios.post('/auth/signin', dataForm))
    func signIn(email: String, password: String) async throws -> AuthResponse {
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]

        return try await apiService.post(
            endpoint: "/api/Auth/login",
            body: body,
            requiresAuth: false
        )
    }

    // MARK: - Sign Up
    func signUp(name: String, email: String, password: String, phone: String) async throws -> AuthResponse {
        let body: [String: Any] = [
            "userName": name,
            "email": email,
            "password": password,
            "phoneNumber": phone
        ]

        return try await apiService.post(
            endpoint: "/api/Auth/register",
            body: body,
            requiresAuth: false
        )
    }

    /// Tries common profile routes; failures are expected if the backend uses a different contract.
    func fetchCurrentUserProfile() async throws -> RemoteUserProfileDTO {
        let paths = [
            "/api/User/profile",
            "/api/User/me",
            "/api/Auth/me",
            "/api/Account/me"
        ]
        var lastError: Error = NetworkError.invalidResponse
        for path in paths {
            do {
                return try await apiService.get(endpoint: path, requiresAuth: true)
            } catch {
                lastError = error
            }
        }
        throw lastError
    }

    /// Changes password for the authenticated user. Tries common ASP.NET-style routes when earlier ones return 404/405.
    func changePassword(currentPassword: String, newPassword: String) async throws {
        struct ChangePasswordResponse: Decodable {
            let message: String?
        }

        let primaryBody: [String: Any] = [
            "currentPassword": currentPassword,
            "newPassword": newPassword,
        ]
        let alternateBody: [String: Any] = [
            "oldPassword": currentPassword,
            "newPassword": newPassword,
        ]

        let pathsAndBodies: [(String, [String: Any])] = [
            (APIEndpoints.Auth.changePassword, primaryBody),
            ("/api/Auth/ChangePassword", primaryBody),
            ("/api/User/change-password", primaryBody),
            ("/api/User/ChangePassword", primaryBody),
            (APIEndpoints.Auth.changePassword, alternateBody),
            ("/api/Auth/ChangePassword", alternateBody),
        ]

        var lastError: Error = NetworkError.invalidResponse

        for (path, body) in pathsAndBodies {
            do {
                let _: ChangePasswordResponse = try await apiService.post(
                    endpoint: path,
                    body: body,
                    requiresAuth: true,
                    treatEmptyResponseAsEmptyJSONObject: true
                )
                return
            } catch {
                lastError = error
                if case NetworkError.httpError(let code, _) = error, code == 404 || code == 405 {
                    continue
                }
                throw error
            }
        }

        throw lastError
    }

    // MARK: - Sign Out (if needed in future)
    func signOut() {
        Task { @MainActor in
            AuthSessionManager.shared.signOut()
        }
    }

    // MARK: - Token Management
    var storedToken: String? {
        UserDefaults.standard.string(forKey: "userToken")
    }

    var isAuthenticated: Bool {
        storedToken != nil
    }
}
