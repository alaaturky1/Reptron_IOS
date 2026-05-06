//
//  CartViewModel.swift
//  SupplementStore
//
//  Created on [Date]
//
//  Shopping cart management matching React CartContext
//  React: { cart, addToCart, removeFromCart, decreaseQuantity, clearCart }
//  Cart items have product properties directly (not nested)
//

import Combine
import Foundation
import SwiftUI

// Cart item structure matching React cart items
// In React, cart items have: { id, name, price, quantity, img, ...productProperties }
struct CartItemModel: Identifiable, Codable, Equatable {
    let lineId: UUID
    let productId: Int
    var serverCartItemId: Int?
    let name: String
    let price: Double
    var quantity: Int // Mutable to allow quantity updates
    let img: String
    let category: String?
    let description: String?
    let oldPrice: Double?
    let onSale: Bool?

    var id: UUID { lineId }

    // Initialize from Product
    init(from product: Product, quantity: Int = 1) {
        self.lineId = UUID()
        self.productId = product.id
        self.serverCartItemId = nil
        self.name = product.name
        self.price = product.price
        self.quantity = quantity
        self.img = product.image
        self.category = product.category
        self.description = product.description
        self.oldPrice = product.oldPrice
        self.onSale = product.onSale
    }

    // Initialize from Equipment
    init(from equipment: Equipment, quantity: Int = 1) {
        self.lineId = UUID()
        self.productId = equipment.id
        self.serverCartItemId = nil
        self.name = equipment.name
        self.price = equipment.price
        self.quantity = quantity
        self.img = equipment.image
        self.category = equipment.specialty
        self.description = equipment.description
        self.oldPrice = equipment.salePrice
        self.onSale = equipment.salePrice != nil
    }

    // Direct initializer
    init(
        lineId: UUID = UUID(),
        productId: Int,
        serverCartItemId: Int? = nil,
        name: String,
        price: Double,
        quantity: Int,
        img: String,
        category: String? = nil,
        description: String? = nil,
        oldPrice: Double? = nil,
        onSale: Bool? = nil
    ) {
        self.lineId = lineId
        self.productId = productId
        self.serverCartItemId = serverCartItemId
        self.name = name
        self.price = price
        self.quantity = quantity
        self.img = img
        self.category = category
        self.description = description
        self.oldPrice = oldPrice
        self.onSale = onSale
    }
}

class CartViewModel: ObservableObject {
    @Published var cart: [CartItemModel] = []
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    private var lastCartUserId: String?

    var grandTotal: Double {
        cart.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    var itemsCount: Int {
        cart.reduce(0) { $0 + $1.quantity }
    }

    init() {
        lastCartUserId = AuthSessionStorage.bridgedActiveUserId
        Task { await refreshCartFromBackendIfAuthenticated() }
        NotificationCenter.default.publisher(for: .authSessionDidSignOut)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.lastCartUserId = nil
                self?.clearCart()
            }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: .authSessionDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let uid = AuthSessionStorage.bridgedActiveUserId
                if uid != self.lastCartUserId {
                    self.lastCartUserId = uid
                    self.clearCart()
                    Task { await self.refreshCartFromBackendIfAuthenticated() }
                }
            }
            .store(in: &cancellables)
    }

    func addToCart(_ product: CartItemModel) {
        cart.append(product)
        Task {
            _ = try? await addCartItemOnBackend(productId: product.productId, quantity: product.quantity)
            await refreshCartFromBackendIfAuthenticated()
        }
    }

    func addProductToCart(_ product: Product, quantity: Int = 1) {
        let cartItem = CartItemModel(from: product, quantity: quantity)
        addToCart(cartItem)
    }

    func addEquipmentToCart(_ equipment: Equipment, quantity: Int = 1) {
        let cartItem = CartItemModel(from: equipment, quantity: quantity)
        addToCart(cartItem)
    }

    func incrementQuantity(_ lineId: UUID) {
        guard let index = cart.firstIndex(where: { $0.lineId == lineId }) else { return }
        var updated = cart[index]
        updated.quantity += 1
        cart[index] = updated
        let serverId = updated.serverCartItemId
        Task {
            _ = try? await updateCartItemOnBackend(itemId: serverId ?? updated.productId, quantity: updated.quantity)
            await refreshCartFromBackendIfAuthenticated()
        }
    }

    func removeFromCart(_ lineId: UUID) {
        guard let item = cart.first(where: { $0.lineId == lineId }) else { return }
        cart.removeAll { $0.lineId == lineId }
        Task {
            if let serverId = item.serverCartItemId {
                _ = try? await deleteCartItemOnBackend(itemId: serverId)
            } else {
                _ = try? await deleteCartItemOnBackend(itemId: item.productId)
            }
            await refreshCartFromBackendIfAuthenticated()
        }
    }

    func decreaseQuantity(_ lineId: UUID) {
        guard let index = cart.firstIndex(where: { $0.lineId == lineId }) else { return }
        var updated = cart[index]
        updated.quantity -= 1
        let serverId = updated.serverCartItemId
        if updated.quantity > 0 {
            cart[index] = updated
            Task {
                _ = try? await updateCartItemOnBackend(itemId: serverId ?? updated.productId, quantity: updated.quantity)
                await refreshCartFromBackendIfAuthenticated()
            }
        } else {
            cart.remove(at: index)
            Task {
                _ = try? await deleteCartItemOnBackend(itemId: serverId ?? updated.productId)
                await refreshCartFromBackendIfAuthenticated()
            }
        }
    }

    func clearCart() {
        cart = []
    }

    private func addCartItemOnBackend(productId: Int, quantity: Int) async throws -> EmptyCartAPIResponse {
        let body: [String: Any] = [
            "productId": productId,
            "quantity": quantity
        ]
        return try await apiService.post(
            endpoint: "/api/Cart/items",
            body: body,
            requiresAuth: true,
            treatEmptyResponseAsEmptyJSONObject: true
        )
    }

    private func updateCartItemOnBackend(itemId: Int, quantity: Int) async throws -> EmptyCartAPIResponse {
        let body: [String: Any] = [
            "quantity": quantity
        ]
        return try await apiService.request(
            endpoint: "/api/Cart/items/\(itemId)",
            method: .PUT,
            body: body,
            requiresAuth: true,
            treatEmptyResponseAsEmptyJSONObject: true
        )
    }

    private func deleteCartItemOnBackend(itemId: Int) async throws -> EmptyCartAPIResponse {
        return try await apiService.request(
            endpoint: "/api/Cart/items/\(itemId)",
            method: .DELETE,
            requiresAuth: true,
            treatEmptyResponseAsEmptyJSONObject: true
        )
    }

    @MainActor
    private func applyBackendCart(_ items: [CartItemModel]) {
        cart = items
    }

    private func refreshCartFromBackendIfAuthenticated() async {
        guard AuthSessionStorage.bridgedActiveUserId != nil else { return }
        guard let token = UserDefaults.standard.string(forKey: "userToken"), !token.isEmpty else { return }
        guard let response: CartJSONValue = try? await apiService.get(endpoint: "/api/Cart", requiresAuth: true) else { return }
        let mapped = Self.mapCartItems(from: response)
        let enriched = await MainActor.run { Self.enrichCartItemImagesFromCatalog(mapped) }
        await applyBackendCart(enriched)
    }

    /// Fills missing `img` after a backend refresh using locally cached catalog (same IDs as store / equipment lists).
    @MainActor
    private static func enrichCartItemImagesFromCatalog(_ items: [CartItemModel]) -> [CartItemModel] {
        items.map { item in
            let trimmed = item.img.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { return item }
            if let p = CatalogCache.shared.product(id: item.productId) {
                let img = p.image.trimmingCharacters(in: .whitespacesAndNewlines)
                if !img.isEmpty {
                    return CartItemModel(
                        lineId: item.lineId,
                        productId: item.productId,
                        serverCartItemId: item.serverCartItemId,
                        name: item.name,
                        price: item.price,
                        quantity: item.quantity,
                        img: p.image,
                        category: item.category,
                        description: item.description,
                        oldPrice: item.oldPrice,
                        onSale: item.onSale
                    )
                }
            }
            if let e = CatalogCache.shared.equipment(id: item.productId) {
                let img = e.image.trimmingCharacters(in: .whitespacesAndNewlines)
                if !img.isEmpty {
                    return CartItemModel(
                        lineId: item.lineId,
                        productId: item.productId,
                        serverCartItemId: item.serverCartItemId,
                        name: item.name,
                        price: item.price,
                        quantity: item.quantity,
                        img: e.image,
                        category: item.category,
                        description: item.description,
                        oldPrice: item.oldPrice,
                        onSale: item.onSale
                    )
                }
            }
            return item
        }
    }

    private static func mapCartItems(from response: CartJSONValue) -> [CartItemModel] {
        let itemObjects = extractItemObjects(from: response)
        return itemObjects.compactMap { raw in
            let serverId = raw.int(forAnyOf: ["cartItemId", "itemId", "id"])
            let productObject = raw.object(forAnyOf: ["product", "equipment"])
            let productId = raw.int(forAnyOf: ["productId"]) ?? productObject?.int(forAnyOf: ["id"])
            let resolvedId = productId ?? serverId ?? 0
            guard resolvedId != 0 else { return nil }

            let name = raw.string(forAnyOf: ["name", "title"])
                ?? productObject?.string(forAnyOf: ["name", "title"])
                ?? "Item"
            let price = raw.double(forAnyOf: ["price", "unitPrice"])
                ?? productObject?.double(forAnyOf: ["price", "unitPrice"])
                ?? 0
            let quantity = max(1, raw.int(forAnyOf: ["quantity", "qty"]) ?? 1)
            let image = raw.string(forAnyOf: ["img", "image", "imageUrl", "imagePath", "photoUrl", "thumbnailUrl", "picture"])
                ?? productObject?.string(forAnyOf: ["img", "image", "imageUrl", "imagePath", "photoUrl", "thumbnailUrl", "picture"])
                ?? ""
            let category = raw.string(forAnyOf: ["category", "specialty"])
                ?? productObject?.string(forAnyOf: ["category", "specialty"])
            let description = raw.string(forAnyOf: ["description", "shortDescription"])
                ?? productObject?.string(forAnyOf: ["description", "shortDescription"])
            let oldPrice = raw.double(forAnyOf: ["oldPrice", "originalPrice", "salePrice"])
                ?? productObject?.double(forAnyOf: ["oldPrice", "originalPrice", "salePrice"])
            let onSale = oldPrice != nil && (oldPrice ?? 0) > price

            return CartItemModel(
                productId: resolvedId,
                serverCartItemId: serverId,
                name: name,
                price: price,
                quantity: quantity,
                img: image,
                category: category,
                description: description,
                oldPrice: oldPrice,
                onSale: onSale
            )
        }
    }

    private static func extractItemObjects(from value: CartJSONValue) -> [[String: CartJSONValue]] {
        if case let .array(arr) = value {
            return arr.compactMap { if case let .object(obj) = $0 { obj } else { nil } }
        }
        guard case let .object(root) = value else { return [] }
        if let directItems = root.objectArray(forAnyOf: ["items", "cartItems"]) {
            return directItems
        }
        if
            let dataValue = root.value(forAnyOf: ["data", "result"]),
            case let .array(arr) = dataValue
        {
            return arr.compactMap { if case let .object(obj) = $0 { obj } else { nil } }
        }
        if
            let dataObj = root.object(forAnyOf: ["data", "result"]),
            let nestedItems = dataObj.objectArray(forAnyOf: ["items", "cartItems"])
        {
            return nestedItems
        }
        return []
    }
}

private struct EmptyCartAPIResponse: Decodable {}

private enum CartJSONValue: Decodable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: CartJSONValue])
    case array([CartJSONValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: CartJSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([CartJSONValue].self) {
            self = .array(value)
        } else {
            throw DecodingError.typeMismatch(
                CartJSONValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON value")
            )
        }
    }
}

private extension Dictionary where Key == String, Value == CartJSONValue {
    func value(forAnyOf keys: [String]) -> CartJSONValue? {
        for key in keys {
            if let v = self[key] { return v }
        }
        return nil
    }

    func string(forAnyOf keys: [String]) -> String? {
        guard let value = value(forAnyOf: keys) else { return nil }
        if case let .string(s) = value { return s }
        return nil
    }

    func int(forAnyOf keys: [String]) -> Int? {
        guard let value = value(forAnyOf: keys) else { return nil }
        switch value {
        case let .int(i): return i
        case let .double(d): return Int(d)
        case let .string(s): return Int(s)
        default: return nil
        }
    }

    func double(forAnyOf keys: [String]) -> Double? {
        guard let value = value(forAnyOf: keys) else { return nil }
        switch value {
        case let .double(d): return d
        case let .int(i): return Double(i)
        case let .string(s): return Double(s)
        default: return nil
        }
    }

    func object(forAnyOf keys: [String]) -> [String: CartJSONValue]? {
        guard let value = value(forAnyOf: keys) else { return nil }
        if case let .object(obj) = value { return obj }
        return nil
    }

    func objectArray(forAnyOf keys: [String]) -> [[String: CartJSONValue]]? {
        guard let value = value(forAnyOf: keys) else { return nil }
        guard case let .array(arr) = value else { return nil }
        let objects = arr.compactMap { item -> [String: CartJSONValue]? in
            if case let .object(obj) = item { return obj }
            return nil
        }
        return objects.isEmpty ? nil : objects
    }
}
