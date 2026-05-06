//
//  AuthSessionManager.swift
//  SupplementStore
//
//  Single source of truth for authenticated user (userId + token + profile fields).
//

import Foundation
import SwiftUI

/// Bridges the active account id for components that are not `@MainActor` (cart, purchases).
/// Written only from `AuthSessionManager`.
enum AuthSessionStorage {
    static let activeUserIdKey = "authSession.activeUserId.v1"

    static var bridgedActiveUserId: String? {
        let s = UserDefaults.standard.string(forKey: activeUserIdKey)?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let s, !s.isEmpty else { return nil }
        return s
    }
}

extension Notification.Name {
    /// Posted when access token / user identity changes (including sign-in and sign-out).
    static let authSessionDidChange = Notification.Name("authSessionDidChange")
    /// Posted after a full sign-out (cart and other per-user caches should reset).
    static let authSessionDidSignOut = Notification.Name("authSessionDidSignOut")
}

// MARK: - JWT (payload only; no signature verification)

enum JWTUserIdExtractor {
    static func userId(from token: String) -> String? {
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return nil }
        var payload = String(parts[1])
        let remainder = payload.count % 4
        if remainder > 0 {
            payload += String(repeating: "=", count: 4 - remainder)
        }
        payload = payload.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        guard let data = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }

        if let sub = json["sub"] as? String, !sub.isEmpty { return sub }
        if let uid = json["userId"] as? Int { return String(uid) }
        if let uid = json["userId"] as? String, !uid.isEmpty { return uid }
        if let nameid = json["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"] as? String {
            return nameid
        }
        if let nameid = json["nameid"] as? String { return nameid }
        return nil
    }
}

// MARK: - Session manager

@MainActor
final class AuthSessionManager: ObservableObject {
    static let shared = AuthSessionManager()

    /// Bearer token used by `APIService` (`userToken` in UserDefaults).
    @Published private(set) var accessToken: String?
    /// Stable account key for scoping local data.
    @Published private(set) var userId: String?
    @Published private(set) var displayName: String?
    @Published private(set) var email: String?
    @Published private(set) var phone: String?
    @Published private(set) var profileRefreshError: String?

    private let persistKey = "authSession.persisted.v1"
    private let userTokenKey = "userToken"

    private struct PersistedSession: Codable, Equatable {
        var token: String
        var userId: String
        var displayName: String?
        var email: String?
        var phone: String?
    }

    var isAuthenticated: Bool {
        guard let t = accessToken, !t.isEmpty else { return false }
        return true
    }

    private init() {
        restore()
    }

    /// Load session from disk (app launch).
    func restore() {
        guard let data = UserDefaults.standard.data(forKey: persistKey),
              let decoded = try? JSONDecoder().decode(PersistedSession.self, from: data)
        else {
            if let legacyToken = UserDefaults.standard.string(forKey: userTokenKey), !legacyToken.isEmpty {
                applyLegacyTokenOnly(legacyToken)
            } else {
                clearLocalStateOnly()
            }
            return
        }
        apply(decoded, postNotifications: false)
        UserDefaults.standard.set(decoded.token, forKey: userTokenKey)
    }

    /// After login / register response.
    func signIn(from response: AuthResponse) async {
        guard let token = response.token, !token.isEmpty else { return }
        let uid = AuthResponse.resolveUserId(user: response.user, token: token)
        let name = response.user?.resolvedDisplayName
        let mail = response.user?.email
        let tel = response.user?.resolvedPhone
        let session = PersistedSession(token: token, userId: uid, displayName: name, email: mail, phone: tel)
        apply(session, postNotifications: true)
        await refreshProfileFromServerIfPossible()
    }

    /// Legacy path when only a raw token is known.
    func applyTokenOnlyForMigration(_ token: String) {
        let uid = JWTUserIdExtractor.userId(from: token) ?? "user_\(abs(token.hashValue))"
        apply(
            PersistedSession(token: token, userId: uid, displayName: nil, email: nil, phone: nil),
            postNotifications: true
        )
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: persistKey)
        UserDefaults.standard.removeObject(forKey: userTokenKey)
        clearLocalStateOnly()
        profileRefreshError = nil
        NotificationCenter.default.post(name: .authSessionDidSignOut, object: nil)
        NotificationCenter.default.post(name: .authSessionDidChange, object: nil)
    }

    /// Local edits from Profile (until a dedicated PATCH API exists).
    func updateEditedProfile(displayName: String?, email: String?) {
        guard let token = accessToken, let uid = userId else { return }
        if let n = displayName { self.displayName = n.isEmpty ? nil : n }
        if let e = email { self.email = e.isEmpty ? nil : e }
        let session = PersistedSession(
            token: token,
            userId: uid,
            displayName: self.displayName,
            email: self.email,
            phone: phone
        )
        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: persistKey)
        }
        objectWillChange.send()
    }

    func refreshProfileFromServerIfPossible() async {
        guard accessToken != nil else { return }
        profileRefreshError = nil
        do {
            let remote = try await AuthService.shared.fetchCurrentUserProfile()
            merge(remote)
            if let token = accessToken, let uid = userId {
                let session = PersistedSession(
                    token: token,
                    userId: uid,
                    displayName: displayName,
                    email: email,
                    phone: phone
                )
                if let data = try? JSONEncoder().encode(session) {
                    UserDefaults.standard.set(data, forKey: persistKey)
                }
            }
            objectWillChange.send()
            NotificationCenter.default.post(name: .authSessionDidChange, object: nil)
        } catch {
            // Some backends do not expose a profile endpoint yet.
            // Treat 404 as "not supported" and keep local session data without surfacing a warning.
            if case NetworkError.httpError(let statusCode, _) = error, statusCode == 404 {
                profileRefreshError = nil
            } else {
                profileRefreshError = error.localizedDescription
            }
        }
    }

    private func applyLegacyTokenOnly(_ token: String) {
        applyTokenOnlyForMigration(token)
    }

    private func apply(_ session: PersistedSession, postNotifications: Bool) {
        accessToken = session.token
        userId = session.userId
        displayName = session.displayName
        email = session.email
        phone = session.phone
        UserDefaults.standard.set(session.userId, forKey: AuthSessionStorage.activeUserIdKey)
        UserDefaults.standard.set(session.token, forKey: userTokenKey)
        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: persistKey)
        }
        if postNotifications {
            NotificationCenter.default.post(name: .authSessionDidChange, object: nil)
        }
        objectWillChange.send()
    }

    private func clearLocalStateOnly() {
        accessToken = nil
        userId = nil
        displayName = nil
        email = nil
        phone = nil
        UserDefaults.standard.removeObject(forKey: AuthSessionStorage.activeUserIdKey)
        objectWillChange.send()
    }

    private func merge(_ remote: RemoteUserProfileDTO) {
        guard userId != nil else { return }
        if let newId = remote.resolvedUserIdString, !newId.isEmpty, newId != userId {
            userId = newId
            UserDefaults.standard.set(newId, forKey: AuthSessionStorage.activeUserIdKey)
        }
        if let n = remote.resolvedName, !n.isEmpty { displayName = n }
        if let e = remote.resolvedEmail, !e.isEmpty { email = e }
        if let p = remote.resolvedPhone, !p.isEmpty { phone = p }
    }
}
