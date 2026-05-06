//
//  PurchaseViewModel.swift
//  SupplementStore
//
//  Created on [Date]
//
//  Purchase history management matching React PurchaseContext
//  React: { purchases, addPurchase }
//  Purchases are stored in localStorage (UserDefaults)
//

import Combine
import Foundation
import SwiftUI

// Purchase model matching React order structure
struct PurchaseOrder: Identifiable, Codable {
    let id: Int
    let date: String // Stored as string to match React: new Date().toLocaleString()
    let items: [CartItemModel] // Cart items directly (matching React: items: [...cart])
    let total: Double
    let shippingAddress: ShippingAddress

    struct ShippingAddress: Codable {
        let name: String
        let address: String
        let city: String
        let postalCode: String
        let country: String
    }

    // Initialize from cart and shipping info
    init(id: Int = Int(Date().timeIntervalSince1970), items: [CartItemModel], total: Double, shippingAddress: ShippingAddress) {
        self.id = id
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        self.date = formatter.string(from: Date())
        self.items = items
        self.total = total
        self.shippingAddress = shippingAddress
    }
}

class PurchaseViewModel: ObservableObject {
    @Published var purchases: [PurchaseOrder] = []
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadPurchases()
        NotificationCenter.default.publisher(for: .authSessionDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadPurchases()
            }
            .store(in: &cancellables)
    }

    func addPurchase(_ order: PurchaseOrder) {
        purchases.append(order)
        savePurchases()
    }

    func submitOrder(shippingAddress: PurchaseOrder.ShippingAddress, paymentMethod: String) async throws {
        let body: [String: Any] = [
            "shippingAddress": "\(shippingAddress.address), \(shippingAddress.city), \(shippingAddress.country), \(shippingAddress.postalCode)",
            "paymentMethod": paymentMethod
        ]
        let _: EmptyAPIResponse = try await apiService.post(
            endpoint: "/api/Orders",
            body: body,
            requiresAuth: true
        )
    }

    private let legacyPurchasesKey = "purchases"

    private func purchasesStorageKey() -> String {
        if let uid = AuthSessionStorage.bridgedActiveUserId {
            return "purchases.\(uid)"
        }
        return "purchases.guest"
    }

    private func loadPurchases() {
        let key = purchasesStorageKey()
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([PurchaseOrder].self, from: data) {
            purchases = decoded.reversed()
            return
        }
        if key != legacyPurchasesKey,
           let legacyData = UserDefaults.standard.data(forKey: legacyPurchasesKey),
           let decoded = try? JSONDecoder().decode([PurchaseOrder].self, from: legacyData) {
            purchases = decoded.reversed()
            savePurchases()
            UserDefaults.standard.removeObject(forKey: legacyPurchasesKey)
            return
        }
        purchases = []
    }

    private func savePurchases() {
        let key = purchasesStorageKey()
        if let encoded = try? JSONEncoder().encode(purchases.reversed()) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    var purchasesReversed: [PurchaseOrder] {
        purchases.reversed()
    }
}

private struct EmptyAPIResponse: Decodable {}
