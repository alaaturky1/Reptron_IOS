import SwiftUI

enum AppTab: Int, CaseIterable, Hashable {
    case home
    case store
    case coaches
    case ai
    case cart
    case profile

    var title: String {
        switch self {
        case .home: return "Home"
        case .store: return "Store"
        case .coaches: return "Coaches"
        case .ai: return "AI"
        case .cart: return "Cart"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .store: return "storefront.fill"
        case .coaches: return "person.2.fill"
        case .ai: return "sparkles"
        case .cart: return "cart.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }

    var route: AppRoute {
        switch self {
        case .home: return .home
        case .store: return .store
        case .coaches: return .coaches
        case .ai: return .ai
        case .cart: return .cart
        case .profile: return .profile
        }
    }
}

struct FooterView: View {
    @Binding var selectedTab: AppTab
    let cartCount: Int
    let aiBadgeCount: Int
    let onTabSelected: (AppTab) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                FooterTabButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    badgeCount: badgeCount(for: tab)
                ) {
                    withAnimation(AppMotion.interactiveSpring) {
                        selectedTab = tab
                    }
                    onTabSelected(tab)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(height: 70)
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.55),
                            Color.white.opacity(0.22),
                            AppTheme.cyan.opacity(0.20)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .overlay(alignment: .top) {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), Color.white.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 5)
                .padding(.horizontal, 28)
                .padding(.top, 2)
                .allowsHitTesting(false)
        }
        .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 8)
        .padding(.horizontal, 18)
        .animation(AppMotion.interactiveSpring, value: selectedTab)
    }

    private func badgeCount(for tab: AppTab) -> Int {
        switch tab {
        case .cart: return cartCount
        case .ai: return aiBadgeCount
        default: return 0
        }
    }
}

struct PageFooterView: View {
    var body: some View {
        VStack(spacing: 10) {
            Divider()
                .overlay(Color.white.opacity(0.15))

            Text("© 2026 Reptron")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.6))
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

private struct FooterTabButton: View {
    let tab: AppTab
    let isSelected: Bool
    let badgeCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 17, weight: .semibold))

                    if badgeCount > 0 {
                        Text("\(badgeCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.red, in: Capsule())
                            .offset(x: 12, y: -8)
                    }
                }

                Text(tab.title)
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(isSelected ? Color.cyan : Color.white.opacity(0.82))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background {
                if isSelected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.cyan.opacity(0.30), AppTheme.cyan.opacity(0.10)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.22), lineWidth: 0.7)
                        )
                        .padding(.horizontal, 6)
                }
            }
            .animation(AppMotion.interactiveSpring, value: isSelected)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FooterView(selectedTab: .constant(.home), cartCount: 2, aiBadgeCount: 3, onTabSelected: { _ in })
        .padding()
        .background(AppTheme.screenGradient)
}
