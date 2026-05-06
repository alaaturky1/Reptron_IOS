//
//  View+Extensions.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

enum AppTheme {
    static let bgTop = Color(red: 8/255, green: 18/255, blue: 34/255)
    static let bgBottom = Color(red: 2/255, green: 7/255, blue: 16/255)
    static let card = Color(red: 20/255, green: 32/255, blue: 52/255)
    static let cardOverlay = Color(red: 30/255, green: 46/255, blue: 72/255)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 196/255, green: 210/255, blue: 228/255)
    static let cyan = Color.cyan
    static let teal = Color(red: 0, green: 188/255, blue: 212/255)
    static let primaryGradient = LinearGradient(
        colors: [cyan, teal],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let screenGradient = LinearGradient(
        colors: [bgTop, bgBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum AppMotion {
    /// Footer tabs, store Supplements/Equipment segment — same feel as scrolling interactions.
    static let interactiveSpring = Animation.spring(response: 0.32, dampingFraction: 0.84)
    /// Main tab root content when switching Home / Store / … (no navigation push).
    static let tabContentSpring = Animation.spring(response: 0.38, dampingFraction: 0.88)
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func appScreenBackground() -> some View {
        self.background(AppTheme.screenGradient.ignoresSafeArea())
    }

    func appCardStyle(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(AppTheme.card.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.cyan.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: AppTheme.teal.opacity(0.12), radius: 10, x: 0, y: 6)
    }

    func appSectionTitle() -> some View {
        self
            .font(.system(size: 30, weight: .heavy))
            .foregroundStyle(AppTheme.primaryGradient)
    }

    /// Navigation bar title using the same gradient + heavy weight as Store’s `appSectionTitle` heading.
    func appStoreStyleNavigationTitle(_ title: String) -> some View {
        self
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(AppTheme.primaryGradient)
                }
            }
    }
}

struct PrimaryGlowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(AppTheme.bgBottom)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(AppTheme.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
            )
            .shadow(color: AppTheme.cyan.opacity(0.22), radius: 10, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(AppTheme.textPrimary)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(AppTheme.cardOverlay.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.cyan.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct APIReadyImageView: View {
    let imagePath: String?
    let placeholderSystemName: String
    let height: CGFloat

    /// Absolute `http(s)` URLs, or paths relative to `APIEndpoints.baseURL` (matches store list / detail payloads).
    private func resolvedImageURL(from path: String?) -> URL? {
        guard let trimmed = path?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            return URL(string: trimmed)
        }
        return APIEndpoints.url(path: trimmed)
    }

    var body: some View {
        if let url = resolvedImageURL(from: imagePath) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholder
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
            .frame(height: height)
            .clipped()
        } else {
            placeholder
                .frame(height: height)
        }
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 30/255, green: 41/255, blue: 59/255))
            Image(systemName: placeholderSystemName)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.cyan.opacity(0.8))
        }
    }
}
