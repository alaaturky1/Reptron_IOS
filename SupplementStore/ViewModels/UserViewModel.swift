//
//  UserViewModel.swift
//  SupplementStore
//
//  Created on [Date]
//
//  User session management matching React UserContext
//  React: { isLogin, setLogin }
//  isLogin can be null (not logged in) or token string (logged in)
//

import Combine
import Foundation
import SwiftUI

@MainActor
class UserViewModel: ObservableObject {
    // Matches React: const [isLogin, setLogin] = useState(null);
    @Published var isLogin: String?

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        _ = AuthSessionManager.shared
        syncFromSession()
        NotificationCenter.default.publisher(for: .authSessionDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.syncFromSession()
            }
            .store(in: &cancellables)
    }

    func syncFromSession() {
        isLogin = AuthSessionManager.shared.accessToken
    }

    var isLoggedIn: Bool {
        isLogin != nil
    }

    /// Prefer signing in via API responses so `AuthSessionManager` owns token + user id.
    func setLogin(_ token: String?) {
        if token == nil {
            AuthSessionManager.shared.signOut()
        } else if let token {
            AuthSessionManager.shared.applyTokenOnlyForMigration(token)
        }
        syncFromSession()
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        let normalizedEmail = Self.normalizeEmail(email)
        let normalizedPassword = Self.normalizePassword(password)

        do {
            let response = try await authService.signIn(email: normalizedEmail, password: normalizedPassword)
            if let token = response.token, !token.isEmpty {
                await AuthSessionManager.shared.signIn(from: response)
                isLogin = AuthSessionManager.shared.accessToken
                isLoading = false
            } else {
                errorMessage = response.message ?? "Login failed"
                isLoading = false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func register(name: String, email: String, password: String, phone: String) async {
        isLoading = true
        errorMessage = nil
        let normalizedName = Self.normalizeName(name)
        let normalizedEmail = Self.normalizeEmail(email)
        let normalizedPassword = Self.normalizePassword(password)
        let normalizedPhone = Self.normalizePhone(phone)

        do {
            let response = try await authService.signUp(
                name: normalizedName,
                email: normalizedEmail,
                password: normalizedPassword,
                phone: normalizedPhone
            )
            if let token = response.token, !token.isEmpty {
                await AuthSessionManager.shared.signIn(from: response)
                isLogin = AuthSessionManager.shared.accessToken
                isLoading = false
            } else {
                errorMessage = response.message ?? "Registration failed"
                isLoading = false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func logout() {
        AuthSessionManager.shared.signOut()
        syncFromSession()
    }

    /// Client-side rules mirror registration (minimum length, match). Server still validates current password.
    @discardableResult
    func changePassword(currentPassword: String, newPassword: String, confirmNewPassword: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        let cur = Self.normalizePassword(currentPassword)
        let next = Self.normalizePassword(newPassword)
        let confirm = Self.normalizePassword(confirmNewPassword)

        guard !cur.isEmpty else {
            errorMessage = "Enter your current password"
            isLoading = false
            return false
        }
        guard !next.isEmpty else {
            errorMessage = "Enter a new password"
            isLoading = false
            return false
        }
        guard next == confirm else {
            errorMessage = "New password and confirmation do not match"
            isLoading = false
            return false
        }
        guard next.count >= 8 else {
            errorMessage = "New password must be at least 8 characters"
            isLoading = false
            return false
        }
        guard cur != next else {
            errorMessage = "New password must be different from your current password"
            isLoading = false
            return false
        }

        do {
            try await authService.changePassword(currentPassword: cur, newPassword: next)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    private static func normalizeEmail(_ value: String) -> String {
        normalizeDigits(value).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func normalizePassword(_ value: String) -> String {
        normalizeDigits(value).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizeName(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizePhone(_ value: String) -> String {
        normalizeDigits(value).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Convert Arabic/Persian digits to western digits for backend compatibility.
    private static func normalizeDigits(_ value: String) -> String {
        let map: [Character: Character] = [
            "٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4",
            "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9",
            "۰": "0", "۱": "1", "۲": "2", "۳": "3", "۴": "4",
            "۵": "5", "۶": "6", "۷": "7", "۸": "8", "۹": "9"
        ]
        return String(value.map { map[$0] ?? $0 })
    }
}
