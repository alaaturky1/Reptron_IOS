//
//  LayoutView.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

struct LayoutView<Content: View>: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var aiBadgeViewModel: AIBadgeViewModel
    @Binding private var selectedTab: AppTab
    private let showsBottomBar: Bool
    private let floatingBarYOffset: CGFloat = -15
    private let extraTopSafeInset: CGFloat = 15
    let content: Content

    init(
        selectedTab: Binding<AppTab> = .constant(.home),
        showsBottomBar: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self._selectedTab = selectedTab
        self.showsBottomBar = showsBottomBar
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.screenGradient
                .ignoresSafeArea(edges: [.top, .bottom])

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, topContentPadding)
                .padding(.bottom, bottomContentPadding)
                .ignoresSafeArea(edges: .bottom)

            if showsBottomBar && userViewModel.isLoggedIn {
                FooterView(
                    selectedTab: $selectedTab,
                    cartCount: cartViewModel.itemsCount,
                    aiBadgeCount: aiBadgeViewModel.badgeCount
                ) { tab in
                    navigationCoordinator.navigateToTab(tab.route)
                }
                .padding(.bottom, 0)
                .offset(y: floatingBarYOffset)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .task(id: userViewModel.isLoggedIn) {
            guard userViewModel.isLoggedIn else { return }
            await aiBadgeViewModel.refresh()
        }
        .onChange(of: selectedTab) { _, newTab in
            if newTab == .ai {
                Task { await aiBadgeViewModel.refresh() }
            }
        }
    }

    private var bottomContentPadding: CGFloat {
        (showsBottomBar && userViewModel.isLoggedIn) ? 90 : 0
    }

    private var topContentPadding: CGFloat {
        userViewModel.isLoggedIn ? extraTopSafeInset : 0
    }
}

#Preview {
    LayoutView(selectedTab: .constant(.home)) {
        Text("Content")
    }
    .environmentObject(UserViewModel())
    .environmentObject(CartViewModel())
    .environmentObject(NavigationCoordinator())
    .environmentObject(AIBadgeViewModel())
}

// MARK: - AI coach tab badge (Railway backend)

private struct AIBadgePayload: Decodable {
    let count: Int?
    let unreadCount: Int?
    let unread: Int?
    let badge: Int?
    let total: Int?

    var resolved: Int {
        [count, unreadCount, unread, badge, total].compactMap { $0 }.first ?? 0
    }
}

@MainActor
final class AIBadgeViewModel: ObservableObject {
    @Published private(set) var badgeCount = 0

    func refresh() async {
        guard let url = URL(string: "/api/badge-count", relativeTo: URL(string: APIEndpoints.baseURL)) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = UserDefaults.standard.string(forKey: "userToken"), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { return }
            guard (200 ..< 300).contains(http.statusCode) else { return }
            guard let payload = try? JSONDecoder().decode(AIBadgePayload.self, from: data) else { return }
            let next = min(max(payload.resolved, 0), 99)
            badgeCount = next
        } catch {
            // Keep previous count on failure.
        }
    }
}
