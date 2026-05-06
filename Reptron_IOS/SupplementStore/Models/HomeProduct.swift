//
//  HomeProduct.swift
//  SupplementStore
//
//  Created on [Date]
//

import Foundation

struct HomeProduct: Identifiable {
    let id: Int
    let name: String
    let category: String
    let price: Double
    let rating: Double
    let image: String
    let description: String
    let onSale: Bool
    let originalPrice: Double?
}

struct Testimonial: Identifiable {
    let id: Int
    let name: String
    let role: String
    let content: String
    let image: String
}

struct WorkoutProgram: Identifiable {
    let id: Int
    let image: String
    let title: String
    let description: String
}

extension WorkoutProgram {
    static let samples: [WorkoutProgram] = [
        WorkoutProgram(id: 1, image: "Strength Training", title: "Strength Training", description: "Build maximum muscle and increase explosive power."),
        WorkoutProgram(id: 2, image: "Fat Loss", title: "Fat Loss", description: "Burn calories fast with structured HIIT and cardio workouts."),
        WorkoutProgram(id: 3, image: "Endurance", title: "Endurance", description: "Is the ability of an organism to exert itself and remain active for a long period of time.")
    ]

    static func find(by id: Int) -> WorkoutProgram? {
        samples.first(where: { $0.id == id })
    }
}

struct BlogPost: Identifiable {
    let id: Int
    let image: String
    let title: String
    let date: String
}

struct Feature: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let description: String
}

struct Category: Identifiable {
    let id: String
    let name: String
    let icon: String
}

