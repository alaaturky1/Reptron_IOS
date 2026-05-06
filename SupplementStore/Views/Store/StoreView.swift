//
//  StoreView.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI
import UIKit

// MARK: - Device Size Helper
// Local implementation of DeviceSize for StoreView
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

struct StoreView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @StateObject private var viewModel = StoreViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var section: StoreSection

    init(initialSection: StoreSection = .supplements) {
        _section = State(initialValue: initialSection)
    }

    private var sectionBinding: Binding<StoreSection> {
        Binding(
            get: { section },
            set: { newValue in
                withAnimation(AppMotion.interactiveSpring) {
                    section = newValue
                }
            }
        )
    }

    private var gridColumns: [GridItem] {
        let spacing = DeviceSize.spacing(base: 16)
        if horizontalSizeClass == .compact {
            return [GridItem(.flexible(), spacing: spacing)]
        } else {
            return [
                GridItem(.flexible(), spacing: spacing),
                GridItem(.flexible(), spacing: spacing)
            ]
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DeviceSize.spacing(base: 24)) {
                VStack(spacing: DeviceSize.spacing(base: 8)) {
                    Text("Store")
                        .appSectionTitle()
                        .multilineTextAlignment(.center)

                    Text("Supplements and gym equipment")
                        .font(.system(size: DeviceSize.fontSize(base: 18)))
                        .foregroundColor(AppTheme.textSecondary)
                        .opacity(0.9)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, DeviceSize.padding(base: 32))
                .padding(.bottom, DeviceSize.padding(base: 8))

                Picker("Store section", selection: sectionBinding) {
                    ForEach(StoreSection.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .tint(AppTheme.cyan)
                .padding(.horizontal, DeviceSize.padding(base: 16))

                Group {
                    switch section {
                    case .supplements:
                        supplementsContent
                    case .equipment:
                        EquipmentsCatalogSection(embeddedInStore: true)
                    }
                }
                .animation(AppMotion.interactiveSpring, value: section)

                Spacer(minLength: DeviceSize.spacing(base: 8))
            }
        }
        .appScreenBackground()
    }

    @ViewBuilder
    private var supplementsContent: some View {
        if viewModel.products.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "box")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("No Products Available")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("We're currently updating our inventory. Please check back soon!")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.vertical, 64)
        } else {
            LazyVGrid(columns: gridColumns, spacing: DeviceSize.spacing(base: 16)) {
                ForEach(viewModel.products.map { StoreProduct(from: $0) }) { product in
                    ProductCard(
                        product: ProductCardStoreProduct(from: product)
                    ) {
                        navigationCoordinator.navigate(to: .productDetails(id: product.id))
                    }
                }
            }
            .padding(.horizontal, DeviceSize.padding(base: 16))
        }
    }
}

#Preview {
    NavigationStack {
        StoreView()
            .environmentObject(NavigationCoordinator())
    }
}
