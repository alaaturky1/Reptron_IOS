//
//  View+Navigation.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

extension View {
    func navigate(to route: AppRoute, coordinator: NavigationCoordinator) {
        coordinator.navigate(to: route)
    }
}

// Navigation helper functions
struct NavigationHelper {
    static func navigateToLogin(coordinator: NavigationCoordinator) {
        coordinator.navigateToLogin()
    }
    
    static func navigateToRegister(coordinator: NavigationCoordinator) {
        coordinator.navigateToRoot()
        coordinator.navigate(to: .register)
    }
    
    static func navigateToHome(coordinator: NavigationCoordinator) {
        coordinator.navigateToRoot()
    }
    
    static func navigateToStore(coordinator: NavigationCoordinator) {
        coordinator.navigate(to: .store)
    }
    
    static func navigateToProduct(coordinator: NavigationCoordinator, productId: Int) {
        coordinator.navigate(to: .productDetails(id: productId))
    }
    
    static func navigateToEquipment(coordinator: NavigationCoordinator, equipmentId: Int) {
        coordinator.navigate(to: .equipmentDetails(id: equipmentId))
    }
    
    static func navigateToCoaches(coordinator: NavigationCoordinator) {
        coordinator.navigate(to: .coaches)
    }
    
    static func navigateToCoach(coordinator: NavigationCoordinator, coachId: Int) {
        coordinator.navigate(to: .coach(id: coachId))
    }
    
    static func navigateToCoachProfile(coordinator: NavigationCoordinator, coachId: Int) {
        coordinator.navigate(to: .coachesProfiles(id: coachId))
    }
    
    static func navigateToCart(coordinator: NavigationCoordinator) {
        coordinator.navigate(to: .cart)
    }
    
    static func navigateToCheckout(coordinator: NavigationCoordinator) {
        coordinator.navigate(to: .checkout)
    }
    
    static func navigateToMyPurchases(coordinator: NavigationCoordinator) {
        coordinator.navigate(to: .myPurchases)
    }
    
    static func navigateToAboutUs(coordinator: NavigationCoordinator) {
        coordinator.navigate(to: .aboutUs)
    }
}

