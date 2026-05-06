//
//  EquipmentsView.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI
import UIKit

// MARK: - Device Size Helper
// Local implementation of DeviceSize for EquipmentsView
private enum DeviceSize {
    // Base values are for iPhone 12/13/14 (390x844 points)
    private static let baseScreenWidth: CGFloat = 390
    
    // Calculate a scaled value based on the current device width
    private static func scaleValue(_ value: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return value * (screenWidth / baseScreenWidth)
    }
    
    // MARK: - Spacing
    static func spacing(base: CGFloat) -> CGFloat { scaleValue(base) }
    
    // MARK: - Padding
    static func padding(base: CGFloat) -> CGFloat { scaleValue(base) }
    
    // MARK: - Font Size
    static func fontSize(base: CGFloat) -> CGFloat { scaleValue(base) }
    
    // MARK: - Corner Radius
    static func cornerRadius(base: CGFloat) -> CGFloat { scaleValue(base) }
}

/// Equipment filters + grid; use `embeddedInStore` when placed inside `StoreView`.
struct EquipmentsCatalogSection: View {
    @StateObject private var viewModel = EquipmentsViewModel()
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var activeFilter: String = "all"
    var embeddedInStore: Bool = false

    private var filteredEquipments: [Equipment] {
        if activeFilter == "all" {
            return viewModel.equipments
        }
        return viewModel.equipments.filter { $0.specialty.lowercased() == activeFilter.lowercased() }
    }

    private var specialties: [String] {
        var allSpecialties = ["all"]
        allSpecialties.append(contentsOf: Set(viewModel.equipments.map { $0.specialty }))
        return allSpecialties
    }

    var body: some View {
        VStack(spacing: DeviceSize.spacing(base: 24)) {
            if !embeddedInStore {
                Text("Equipment")
                    .appSectionTitle()
                    .padding(.top, DeviceSize.padding(base: 32))
            }

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
                                .background {
                                    if activeFilter == specialty {
                                        AppTheme.primaryGradient
                                    } else {
                                        AppTheme.cardOverlay
                                    }
                                }
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, DeviceSize.padding(base: 16))
            }

            if filteredEquipments.isEmpty {
                VStack(spacing: DeviceSize.spacing(base: 16)) {
                    Text("No equipment found")
                        .font(.system(size: DeviceSize.fontSize(base: 18)))
                        .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                }
                .padding(.vertical, DeviceSize.padding(base: 64))
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: DeviceSize.spacing(base: 16)),
                        GridItem(.flexible(), spacing: DeviceSize.spacing(base: 16))
                    ],
                    spacing: DeviceSize.spacing(base: 16)
                ) {
                    ForEach(filteredEquipments) { equipment in
                        EquipmentCard(equipment: equipment) {
                            navigationCoordinator.navigate(to: .equipmentDetails(id: equipment.id))
                        }
                    }
                }
                .padding(.horizontal, DeviceSize.padding(base: 16))
            }

            if !embeddedInStore {
                PageFooterView()
            }
        }
    }
}

struct EquipmentsView: View {
    var body: some View {
        ScrollView {
            EquipmentsCatalogSection(embeddedInStore: false)
        }
        .appScreenBackground()
    }
}

struct EquipmentCard: View {
    let equipment: Equipment
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                APIReadyImageView(
                    imagePath: equipment.image,
                    placeholderSystemName: "dumbbell.fill",
                    height: 150
                )
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 12)) {
                    Text(equipment.name)
                        .font(.system(size: DeviceSize.fontSize(base: 18), weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                    
                    HStack {
                        if let salePrice = equipment.salePrice {
                            Text("$\(String(format: "%.2f", equipment.price))")
                                .font(.system(size: DeviceSize.fontSize(base: 14)))
                                .foregroundColor(AppTheme.textSecondary)
                                .strikethrough()
                            Text("$\(String(format: "%.2f", salePrice))")
                                .font(.system(size: DeviceSize.fontSize(base: 20), weight: .bold))
                                .foregroundColor(AppTheme.cyan)
                        } else {
                            Text("$\(String(format: "%.2f", equipment.price))")
                                .font(.system(size: DeviceSize.fontSize(base: 20), weight: .bold))
                                .foregroundColor(AppTheme.cyan)
                        }
                        Spacer(minLength: 0)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DeviceSize.padding(base: 16))
            }
            .appCardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    EquipmentsView()
        .environmentObject(NavigationCoordinator())
}
