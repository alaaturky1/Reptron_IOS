//
//  ContentView.swift
//  SupplementStore
//
//  Created on [Date]
//
//  This file is kept for compatibility but MainAppView is the main entry point
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainAppView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthSessionManager.shared)
        .environmentObject(UserViewModel())
        .environmentObject(CartViewModel())
        .environmentObject(PurchaseViewModel())
        .environmentObject(NavigationCoordinator())
        .environmentObject(AIBadgeViewModel())
        .environmentObject(WorkoutHistoryStore())
}

