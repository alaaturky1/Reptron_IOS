//
//  NavigationCoordinator.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    /// Applied on next MainAppView tab render for programmatic `navigate(to:)` on primary routes.
    @Published private(set) var pendingMainTab: AppTab?
    @Published private(set) var storeLaunchSection: StoreSection = .supplements
    @Published private(set) var storePresentationID = UUID()

    func navigate(to route: AppRoute) {
        if let tab = route.primaryTab {
            navigateToRoot()
            pendingMainTab = tab
            switch route {
            case .equipments:
                storeLaunchSection = .equipment
                storePresentationID = UUID()
            case .store:
                storeLaunchSection = .supplements
                storePresentationID = UUID()
            default:
                break
            }
            return
        }
        path.append(route)
    }

    func navigateToTab(_ route: AppRoute) {
        navigateToRoot()
        if route == .store {
            storeLaunchSection = .supplements
            storePresentationID = UUID()
        }
    }

    func consumePendingMainTab() {
        pendingMainTab = nil
    }

    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func navigateToRoot() {
        path.removeLast(path.count)
    }

    func navigateToLogin() {
        navigateToRoot()
        path.append(AppRoute.login)
    }
}
