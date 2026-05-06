//
//  Product.swift
//  SupplementStore
//
//  Created on [Date]
//
//  Product data structures matching React Store and ProductDetails components
//

import Foundation

// MARK: - Store Product (Simple structure from Store.jsx)
// React: { id, img, name, price, oldPrice }
struct StoreProduct: Identifiable, Codable {
    let id: Int
    let img: String?
    let name: String
    let price: Double
    let oldPrice: Double?
    
    // Computed property for sale status
    var onSale: Bool {
        return oldPrice != nil
    }
    
}

// MARK: - Full Product (Detailed structure from ProductDetails.jsx)
// React: { id, img, name, price, oldPrice, description, additionalInfo, reviews }
struct Product: Identifiable, Codable {
    let id: Int
    let img: String?
    let name: String
    let price: Double
    let oldPrice: Double?
    let description: String
    let additionalInfo: String?
    let reviews: [Review]?
    
    // Optional fields for compatibility with other views
    var rating: Double? = nil  // Not in Store/ProductDetails, but used in Home
    
    // Computed properties
    var onSale: Bool {
        return oldPrice != nil
    }
    
    var image: String {
        return img ?? ""
    }
    
    var category: String {
        return "supplements"  // All store products are supplements
    }
    
    static let sample = Product(
        id: 0,
        img: nil,
        name: "Loading...",
        price: 0,
        oldPrice: nil,
        description: "Product details will come from backend.",
        additionalInfo: nil,
        reviews: []
    )

    static func placeholder(id: Int) -> Product {
        Product(
            id: id,
            img: nil,
            name: "Product",
            price: 0,
            oldPrice: nil,
            description: "Product details will load from backend.",
            additionalInfo: nil,
            reviews: []
        )
    }
    
    // Find product by ID
    static func find(by id: Int) -> Product? {
        return placeholder(id: id)
    }
}

// MARK: - Review
// React: { name, rating, comment }
struct Review: Codable, Identifiable {
    let id = UUID()
    let name: String
    let rating: Int  // 1-5 stars
    let comment: String
    
    // Custom CodingKeys to exclude id from encoding
    enum CodingKeys: String, CodingKey {
        case name, rating, comment
    }
}

// MARK: - Extensions for compatibility

extension StoreProduct {
    // Convert StoreProduct to full Product
    func toProduct() -> Product? {
        return Product(
            id: id,
            img: img,
            name: name,
            price: price,
            oldPrice: oldPrice,
            description: "",
            additionalInfo: nil,
            reviews: nil
        )
    }
}

extension Product {
    // Convert Product to StoreProduct
    func toStoreProduct() -> StoreProduct {
        return StoreProduct(
            id: id,
            img: img,
            name: name,
            price: price,
            oldPrice: oldPrice
        )
    }
}

extension StoreProduct {
    init(from product: Product) {
        self.id = product.id
        self.img = product.img
        self.name = product.name
        self.price = product.price
        self.oldPrice = product.oldPrice
    }
}

@MainActor
final class CatalogCache {
    static let shared = CatalogCache()

    private var productsById: [Int: Product] = [:]
    private var equipmentsById: [Int: Equipment] = [:]

    private init() {}

    func store(products: [Product]) {
        productsById = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
    }

    func store(equipments: [Equipment]) {
        equipmentsById = Dictionary(uniqueKeysWithValues: equipments.map { ($0.id, $0) })
    }

    func product(id: Int) -> Product? {
        productsById[id]
    }

    func equipment(id: Int) -> Equipment? {
        equipmentsById[id]
    }
}
