//
//  EquipmentsViewModel.swift
//  SupplementStore
//
//  Created on [Date]
//

import Foundation
import SwiftUI

class EquipmentsViewModel: ObservableObject {
    @Published var equipments: [Equipment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        loadEquipments()
    }
    
    private func loadEquipments() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                guard let url = APIEndpoints.url(path: APIEndpoints.Equipment.all) else {
                    throw URLError(.badURL)
                }
                let (data, response) = try await URLSession.shared.data(from: url)
                try Self.validateHTTP(response: response)
                let rawItems = try Self.extractArrayPayload(from: data)
                let mapped = rawItems.compactMap { Self.mapEquipment(from: $0) }
                
                await MainActor.run {
                    self.equipments = mapped
                    self.isLoading = false
                }
                await MainActor.run {
                    CatalogCache.shared.store(equipments: mapped)
                }
            } catch {
                await MainActor.run {
                    self.equipments = []
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private static func validateHTTP(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    private static func extractArrayPayload(from data: Data) throws -> [[String: Any]] {
        let json = try JSONSerialization.jsonObject(with: data)
        if let arr = json as? [[String: Any]] {
            return arr
        }
        if
            let dict = json as? [String: Any],
            let arr = (dict["data"] as? [[String: Any]]) ?? (dict["items"] as? [[String: Any]])
        {
            return arr
        }
        return []
    }

    private static func mapEquipment(from raw: [String: Any]) -> Equipment? {
        let id = int(from: raw["id"]) ?? int(from: raw["equipmentId"]) ?? 0
        guard id != 0 else { return nil }
        
        let name = raw["name"] as? String ?? "Equipment"
        let description = raw["description"] as? String ?? (raw["shortDescription"] as? String ?? "")
        let specialty = raw["specialty"] as? String ?? (raw["category"] as? String ?? "")
        
        return Equipment(
            id: id,
            name: name,
            specialty: specialty,
            price: double(from: raw["price"]) ?? double(from: raw["unitPrice"]) ?? 0,
            salePrice: double(from: raw["salePrice"]) ?? double(from: raw["originalPrice"]),
            image: raw["image"] as? String ?? raw["imageUrl"] as? String ?? raw["img"] as? String ?? "",
            description: description,
            additionalInfo: raw["additionalInfo"] as? String,
            reviews: nil,
            bio: raw["bio"] as? String ?? ""
        )
    }

    private static func int(from value: Any?) -> Int? {
        switch value {
        case let v as Int:
            return v
        case let v as Double:
            return Int(v)
        case let v as String:
            return Int(v)
        default:
            return nil
        }
    }

    private static func double(from value: Any?) -> Double? {
        switch value {
        case let v as Double:
            return v
        case let v as Int:
            return Double(v)
        case let v as String:
            return Double(v)
        default:
            return nil
        }
    }
}

