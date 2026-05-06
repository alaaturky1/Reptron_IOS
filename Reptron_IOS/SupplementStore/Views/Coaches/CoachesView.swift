//
//  CoachesView.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI
import UIKit

// MARK: - Device Size Helper
// Local implementation of DeviceSize for CoachesView
private enum DeviceSize {
    private static let baseScreenWidth: CGFloat = 390
    
    private static func scaleValue(_ value: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return value * (screenWidth / baseScreenWidth)
    }
    
    static func spacing(base: CGFloat) -> CGFloat { scaleValue(base) }
    static func padding(base: CGFloat) -> CGFloat { scaleValue(base) }
    static func fontSize(base: CGFloat) -> CGFloat { scaleValue(base) }
    static func cornerRadius(base: CGFloat) -> CGFloat { scaleValue(base) }
}
struct CoachesView: View {
    @StateObject private var viewModel = CoachesViewModel()
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var activeFilter: String = "all"
    
    private var filteredCoaches: [Coach] {
        if activeFilter == "all" {
            return viewModel.coaches
        }
        return viewModel.coaches.filter { $0.specialty.lowercased() == activeFilter.lowercased() }
    }
    
    private var specialties: [String] {
        var allSpecialties = ["all"]
        allSpecialties.append(contentsOf: Set(viewModel.coaches.map { $0.specialty }))
        return allSpecialties
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DeviceSize.spacing(base: 24)) {
                // Header
                Text("Our Coaches")
                    .appSectionTitle()
                    .padding(.top, DeviceSize.padding(base: 32))
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DeviceSize.spacing(base: 12)) {
                        ForEach(specialties, id: \.self) { specialty in
                            Button(action: {
                                activeFilter = specialty
                            }) {
                                Text(specialty.capitalized)
                                    .font(.system(size: DeviceSize.fontSize(base: 14), weight: .semibold))
                                    .foregroundColor(activeFilter == specialty ? AppTheme.bgBottom : .white)
                                    .padding(.horizontal, DeviceSize.padding(base: 16))
                                    .padding(.vertical, DeviceSize.padding(base: 10))
                                    .background(
                                        activeFilter == specialty ?
                                        AppTheme.primaryGradient :
                                        LinearGradient(
                                            colors: [AppTheme.cardOverlay, AppTheme.cardOverlay],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, DeviceSize.padding(base: 16))
                }
                
                // Coaches Grid
                if filteredCoaches.isEmpty {
                    VStack(spacing: DeviceSize.spacing(base: 16)) {
                        Text("No coaches found")
                            .font(.system(size: DeviceSize.fontSize(base: 18)))
                            .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                    }
                    .padding(.vertical, DeviceSize.padding(base: 64))
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: DeviceSize.spacing(base: 16)),
                        GridItem(.flexible(), spacing: DeviceSize.spacing(base: 16))
                    ], spacing: DeviceSize.spacing(base: 16)) {
                        ForEach(filteredCoaches) { coach in
                            CoachCard(coach: coach) {
                                navigationCoordinator.navigate(to: .coach(id: coach.id))
                            }
                        }
                    }
                    .padding(.horizontal, DeviceSize.padding(base: 16))
                }

                PageFooterView()
            }
        }
        .appScreenBackground()
    }
}

struct CoachCard: View {
    let coach: Coach
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DeviceSize.spacing(base: 12)) {
                APIReadyImageView(
                    imagePath: coach.image,
                    placeholderSystemName: "person.fill",
                    height: 150
                )
                .frame(maxWidth: .infinity)
                .cornerRadius(12, corners: [.topLeft, .topRight])
                
                VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 8)) {
                    Text(coach.name)
                        .font(.system(size: DeviceSize.fontSize(base: 18), weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    Text(coach.specialty)
                        .font(.system(size: DeviceSize.fontSize(base: 14)))
                        .foregroundColor(Color.cyan)
                        .lineLimit(1)
                    
                    Text(coach.bio)
                        .font(.system(size: DeviceSize.fontSize(base: 12)))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DeviceSize.padding(base: 12))
            }
            .appCardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CoachesView()
        .environmentObject(NavigationCoordinator())
}
