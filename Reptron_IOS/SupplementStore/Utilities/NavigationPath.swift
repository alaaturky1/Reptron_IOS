//
//  NavigationPath.swift
//  SupplementStore
//
//  Created on [Date]
//

import Foundation

// Navigation paths matching React Router structure
enum AppRoute: Hashable {
    // Public routes
    case home
    case login
    case register
    
    // Account
    case profile
    
    // Content
    case workoutProgram(id: Int)
    
    // Protected routes
    case aboutUs
    case coaches
    case coach(id: Int)
    case coachesProfiles(id: Int)
    case equipments
    case equipmentDetails(id: Int)
    case store
    case productDetails(id: Int)
    case cart
    case checkout
    case myPurchases
    case ai
    
    // Error route
    case notFound
}

enum StoreSection: String, CaseIterable, Hashable {
    case supplements = "Supplements"
    case equipment = "Equipment"
}

extension AppRoute {
    /// Routes that show a main shell tab (no stack push — same as Home root).
    var primaryTab: AppTab? {
        switch self {
        case .home: return .home
        case .store, .equipments: return .store
        case .coaches: return .coaches
        case .ai: return .ai
        case .cart: return .cart
        case .profile: return .profile
        default: return nil
        }
    }
}
