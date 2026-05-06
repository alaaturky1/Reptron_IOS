//
//  Purchase.swift
//  SupplementStore
//
//  Created on [Date]
//

import Foundation

struct Purchase: Identifiable, Codable {
    let id: Int
    let date: Date
    let items: [CartItem]
    let total: Double
    let shippingAddress: ShippingAddress
    
    struct ShippingAddress: Codable {
        let name: String
        let address: String
        let city: String
        let postalCode: String
        let country: String
    }
}

extension CartItem: Codable {
    enum CodingKeys: String, CodingKey {
        case product, quantity
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        product = try container.decode(Product.self, forKey: .product)
        quantity = try container.decode(Int.self, forKey: .quantity)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(product, forKey: .product)
        try container.encode(quantity, forKey: .quantity)
    }
}

