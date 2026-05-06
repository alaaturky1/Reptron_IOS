//
//  SupplementStoreApp.swift
//  SupplementStore
//
//  Created on [Date]
//
//

import SwiftUI

@main
struct SupplementStoreApp: App {
    // State objects matching React Context Providers
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var purchaseViewModel = PurchaseViewModel()
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @StateObject private var aiBadgeViewModel = AIBadgeViewModel()
    @StateObject private var workoutHistoryStore = WorkoutHistoryStore()

    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(AuthSessionManager.shared)
                .environmentObject(userViewModel)
                .environmentObject(cartViewModel)
                .environmentObject(purchaseViewModel)
                .environmentObject(navigationCoordinator)
                .environmentObject(aiBadgeViewModel)
                .environmentObject(workoutHistoryStore)
        }
    }
}

//
//  MainAppView.swift
//  SupplementStore
//
//  Main app view that handles navigation and layout
//

struct MainAppView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedTab: AppTab = .home
    @State private var didSetInitialLoggedInTab = false

    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            rootContentView
                .navigationDestination(for: AppRoute.self) { route in
                    stackedDestination(for: route)
                }
        }
        .onReceive(userViewModel.$isLogin) { login in
            if login == nil {
                selectedTab = .home
            }
        }
        .onChange(of: navigationCoordinator.pendingMainTab) { _, tab in
            guard let tab else { return }
            guard userViewModel.isLoggedIn else {
                navigationCoordinator.consumePendingMainTab()
                return
            }
            withAnimation(AppMotion.interactiveSpring) {
                selectedTab = tab
            }
            navigationCoordinator.consumePendingMainTab()
        }
    }

    // MARK: - Root Content View
    @ViewBuilder
    private var rootContentView: some View {
        if userViewModel.isLoggedIn {
            loggedInShell
                .onAppear {
                    guard !didSetInitialLoggedInTab else { return }
                    selectedTab = .home
                    didSetInitialLoggedInTab = true
                }
        } else {
            LayoutView(showsBottomBar: false) {
                HomeView()
            }
            .onAppear {
                didSetInitialLoggedInTab = false
            }
        }
    }

    /// Main tabs swap inside the navigation root (like staying on Home) — only detail routes use stack push.
    private var loggedInShell: some View {
        LayoutView(selectedTab: $selectedTab) {
            mainTabRootContent
                .id(selectedTab)
                .transition(.opacity)
        }
        .animation(AppMotion.tabContentSpring, value: selectedTab)
    }

    @ViewBuilder
    private var mainTabRootContent: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .store:
            ProtectedRoute {
                StoreView(initialSection: navigationCoordinator.storeLaunchSection)
                    .id(navigationCoordinator.storePresentationID)
            }
        case .coaches:
            ProtectedRoute {
                CoachesView()
            }
        case .ai:
            AIFitnessCoachRootView()
        case .cart:
            ProtectedRoute {
                CartView()
            }
        case .profile:
            ProfileView()
        }
    }

    // MARK: - Stacked destinations (push / pop like detail flows)
    @ViewBuilder
    private func stackedDestination(for route: AppRoute) -> some View {
        switch route {
        case .home, .store, .equipments, .coaches, .ai, .cart, .profile:
            EmptyView()

        case .login:
            LayoutView(showsBottomBar: false) {
                LoginView()
            }

        case .register:
            LayoutView(showsBottomBar: false) {
                RegisterView()
            }

        case .workoutProgram(let id):
            LayoutView(selectedTab: $selectedTab) {
                if let program = WorkoutProgram.find(by: id) {
                    WorkoutProgramDetailsView(program: program)
                } else {
                    NotFoundView()
                }
            }
            .onAppear { selectedTab = .home }

        case .aboutUs:
            LayoutView(selectedTab: $selectedTab) {
                ProtectedRoute {
                    AboutUsView()
                }
            }
            .onAppear { selectedTab = .home }

        case .coach(let id):
            LayoutView(selectedTab: $selectedTab) {
                ProtectedRoute {
                    CoachDetailsView(coach: Coach.placeholder(id: id))
                }
            }
            .onAppear { selectedTab = .coaches }

        case .coachesProfiles(let id):
            LayoutView(selectedTab: $selectedTab) {
                ProtectedRoute {
                    CoachesProfilesView(coach: Coach.placeholder(id: id))
                }
            }
            .onAppear { selectedTab = .coaches }

        case .equipmentDetails(let id):
            LayoutView(selectedTab: $selectedTab) {
                ProtectedRoute {
                    EquipmentsDetailsView(equipment: Equipment.placeholder(id: id))
                }
            }
            .onAppear { selectedTab = .store }

        case .productDetails(let id):
            LayoutView(selectedTab: $selectedTab) {
                ProtectedRoute {
                    if let product = Product.find(by: id) {
                        ProductDetailsView(product: product)
                    } else {
                        NotFoundView()
                    }
                }
            }
            .onAppear { selectedTab = .store }

        case .checkout:
            LayoutView(selectedTab: $selectedTab) {
                ProtectedRoute {
                    CheckoutView()
                }
            }

        case .myPurchases:
            LayoutView(selectedTab: $selectedTab) {
                ProtectedRoute {
                    MyPurchasesView()
                }
            }

        case .notFound:
            LayoutView(selectedTab: $selectedTab) {
                NotFoundView()
            }
            .onAppear { selectedTab = .home }
        }
    }
}

#Preview {
    MainAppView()
        .environmentObject(AuthSessionManager.shared)
        .environmentObject(UserViewModel())
        .environmentObject(CartViewModel())
        .environmentObject(PurchaseViewModel())
        .environmentObject(NavigationCoordinator())
        .environmentObject(AIBadgeViewModel())
        .environmentObject(WorkoutHistoryStore())
}
