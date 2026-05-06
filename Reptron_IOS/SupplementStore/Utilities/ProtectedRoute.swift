//
//  ProtectedRoute.swift
//  SupplementStore
//
//  Created on [Date]
//
//  Protected route wrapper matching React Router ProtectedRoute component
//

import SwiftUI

struct ProtectedRoute<Content: View>: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            if userViewModel.isLoggedIn {
                content
            } else {
                // Redirect to login if not authenticated (matches React behavior)
                LoginView()
                    .onAppear {
                        // Navigate to login route
                        navigationCoordinator.navigateToLogin()
                    }
            }
        }
    }
}

