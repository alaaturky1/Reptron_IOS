//
//  RootView.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @StateObject private var aiBadgeViewModel = AIBadgeViewModel()
    @StateObject private var workoutHistoryStore = WorkoutHistoryStore()

    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            Group {
                if userViewModel.isLoggedIn {
                    // When logged in, show MainTabView (matches React Router protected routes)
                    MainTabView()
                        .navigationDestination(for: AppRoute.self) { route in
                            destinationView(for: route)
                        }
                } else {
                    // When not logged in, show Layout with public routes
                    LayoutView {
                        HomeView()
                            .navigationDestination(for: AppRoute.self) { route in
                                destinationView(for: route)
                            }
                    }
                }
            }
        }
        .environmentObject(AuthSessionManager.shared)
        .environmentObject(navigationCoordinator)
        .environmentObject(aiBadgeViewModel)
        .environmentObject(workoutHistoryStore)
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        // Public routes (no layout wrapper for login/register)
        case .home:
            if userViewModel.isLoggedIn {
                MainTabView()
            } else {
                LayoutView {
                    HomeView()
                }
            }
        case .login:
            LayoutView {
                LoginView()
            }
        case .register:
            LayoutView {
                RegisterView()
            }

        case .profile:
            LayoutView {
                ProfileView()
            }

        case .workoutProgram(let id):
            LayoutView {
                if let program = WorkoutProgram.find(by: id) {
                    WorkoutProgramDetailsView(program: program)
                } else {
                    NotFoundView()
                }
            }
            
        // Protected routes (wrapped in LayoutView to match React structure)
        case .aboutUs:
            LayoutView {
                ProtectedRoute {
                    AboutUsView()
                }
            }
        case .coaches:
            LayoutView {
                ProtectedRoute {
                    CoachesView()
                }
            }
        case .coach(let id):
            LayoutView {
                ProtectedRoute {
                    CoachDetailsView(coach: Coach.placeholder(id: id))
                }
            }
        case .coachesProfiles(let id):
            LayoutView {
                ProtectedRoute {
                    CoachesProfilesView(coach: Coach.placeholder(id: id))
                }
            }
        case .equipments:
            LayoutView {
                ProtectedRoute {
                    StoreView(initialSection: .equipment)
                }
            }
        case .equipmentDetails(let id):
            LayoutView {
                ProtectedRoute {
                    EquipmentsDetailsView(
                        equipment: CatalogCache.shared.equipment(id: id) ?? Equipment.placeholder(id: id)
                    )
                }
            }
        case .store:
            LayoutView {
                ProtectedRoute {
                    StoreView()
                }
            }
        case .productDetails(let id):
            LayoutView {
                ProtectedRoute {
                    ProductDetailsView(product: CatalogCache.shared.product(id: id) ?? Product.placeholder(id: id))
                }
            }
        case .cart:
            LayoutView {
                ProtectedRoute {
                    CartView()
                }
            }
        case .ai:
            LayoutView {
                AIFitnessCoachRootView()
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
        case .checkout:
            LayoutView {
                ProtectedRoute {
                    CheckoutView()
                }
            }
        case .myPurchases:
            LayoutView {
                ProtectedRoute {
                    MyPurchasesView()
                }
            }
            
        // Error route
        case .notFound:
            LayoutView {
                NotFoundView()
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthSessionManager.shared)
        .environmentObject(UserViewModel())
        .environmentObject(CartViewModel())
        .environmentObject(PurchaseViewModel())
        .environmentObject(AIBadgeViewModel())
        .environmentObject(WorkoutHistoryStore())
}




