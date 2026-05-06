//
//  CartItem.swift
//  SupplementStore
//
//  Created on [Date]
//

import Foundation

struct CartItem: Identifiable {
    let id = UUID()
    var product: Product
    var quantity: Int
}

