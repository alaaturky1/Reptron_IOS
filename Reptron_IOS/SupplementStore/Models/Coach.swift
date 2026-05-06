//
//  Coach.swift
//  SupplementStore
//
//  Created on [Date]
//

import Foundation

struct Coach: Identifiable, Codable {
    let id: Int
    let name: String
    let specialty: String
    let title: String
    let bio: String
    let fullBio: String
    let experience: String
    let clients: String
    let certifications: String
    let image: String
    let phone: String
    let email: String
    let hourlyRate: String?
    let availability: [String]?
    
    static let sample = Coach.placeholder(id: 0)

    static func placeholder(id: Int) -> Coach {
        Coach(
            id: id,
            name: "Coach",
            specialty: "",
            title: "",
            bio: "Coach data will load from backend.",
            fullBio: "Coach data will load from backend.",
            experience: "",
            clients: "",
            certifications: "",
            image: "",
            phone: "",
            email: "",
            hourlyRate: nil,
            availability: nil
        )
    }
}

