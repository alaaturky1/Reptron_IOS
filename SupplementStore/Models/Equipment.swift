//
//  Equipment.swift
//  SupplementStore
//
//  Created on [Date]
//

import Foundation

struct Equipment: Identifiable, Codable {
    let id: Int
    let name: String
    let specialty: String
    let price: Double
    let salePrice: Double?
    let image: String
    let description: String
    let additionalInfo: String?
    let reviews: [Review]?
    let bio: String
    
    static let sample = Equipment.placeholder(id: 0)

    static func placeholder(id: Int) -> Equipment {
        Equipment(
            id: id,
            name: "Equipment",
            specialty: "",
            price: 0,
            salePrice: nil,
            image: "",
            description: "Equipment data will load from backend.",
            additionalInfo: nil,
            reviews: [],
            bio: ""
        )
    }
}

