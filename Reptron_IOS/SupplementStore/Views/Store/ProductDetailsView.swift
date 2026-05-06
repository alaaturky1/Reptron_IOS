//
//  ProductDetailsView.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI
import UIKit

// MARK: - Device Size Helper
// Local implementation of DeviceSize for ProductDetailsView
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

struct ProductDetailsView: View {
    let product: Product
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var resolvedProduct: Product
    @State private var quantity: Int = 1
    @State private var selectedTab: ProductTab = .description
    @State private var isLoadingDetails = false

    init(product: Product) {
        self.product = product
        _resolvedProduct = State(initialValue: product)
    }
    
    enum ProductTab {
        case description, additional, reviews
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Product Image
                APIReadyImageView(
                    imagePath: resolvedProduct.image,
                    placeholderSystemName: "photo",
                    height: 300
                )
                .frame(maxWidth: .infinity)
                .background(Color(red: 30/255, green: 41/255, blue: 59/255))
                
                VStack(spacing: DeviceSize.spacing(base: 24)) {
                    // Product Name and Price
                    VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 12)) {
                        Text(resolvedProduct.name)
                            .font(.system(size: DeviceSize.fontSize(base: 28), weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: DeviceSize.spacing(base: 16)) {
                            Text("$\(String(format: "%.2f", resolvedProduct.price))")
                                .font(.system(size: DeviceSize.fontSize(base: 32), weight: .heavy))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            if let oldPrice = resolvedProduct.oldPrice {
                                Text("$\(String(format: "%.2f", oldPrice))")
                                    .font(.system(size: DeviceSize.fontSize(base: 20)))
                                    .foregroundColor(.red)
                                    .strikethrough()
                            }
                        }

                        HStack(spacing: DeviceSize.spacing(base: 10)) {
                            ProductMetaChip(title: "Category", value: resolvedProduct.category.capitalized)
                            if resolvedProduct.onSale {
                                ProductMetaChip(title: "Status", value: "On Sale")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Quantity Selector
                    HStack(spacing: DeviceSize.spacing(base: 20)) {
                        Text("Quantity:")
                            .font(.system(size: DeviceSize.fontSize(base: 18), weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: DeviceSize.spacing(base: 16)) {
                            Button(action: {
                                if quantity > 1 {
                                    quantity -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: DeviceSize.fontSize(base: 24)))
                                    .foregroundColor(Color.cyan)
                            }
                            
                            Text("\(quantity)")
                                .font(.system(size: DeviceSize.fontSize(base: 20), weight: .bold))
                                .foregroundColor(.white)
                                .frame(minWidth: 40)
                            
                            Button(action: {
                                quantity += 1
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: DeviceSize.fontSize(base: 24)))
                                    .foregroundColor(Color.cyan)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Tabs
                    HStack(spacing: 0) {
                        TabButton(title: "Description", isSelected: selectedTab == .description) {
                            selectedTab = .description
                        }
                        TabButton(title: "Additional Info", isSelected: selectedTab == .additional) {
                            selectedTab = .additional
                        }
                        TabButton(title: "Reviews", isSelected: selectedTab == .reviews) {
                            selectedTab = .reviews
                        }
                    }
                    .padding(.vertical, DeviceSize.padding(base: 8))
                    
                    // Tab Content
                    Group {
                        switch selectedTab {
                        case .description:
                            Text(resolvedProduct.description)
                                .font(.system(size: DeviceSize.fontSize(base: 16)))
                                .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                        case .additional:
                            if let additionalInfo = resolvedProduct.additionalInfo {
                                Text(additionalInfo)
                                    .font(.system(size: DeviceSize.fontSize(base: 16)))
                                    .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text("No additional information available.")
                                    .font(.system(size: DeviceSize.fontSize(base: 16)))
                                    .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255).opacity(0.7))
                            }
                            
                        case .reviews:
                            if let reviews = resolvedProduct.reviews, !reviews.isEmpty {
                                VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 16)) {
                                    ForEach(reviews) { review in
                                        ReviewRow(review: review)
                                    }
                                }
                            } else {
                                Text("No reviews yet.")
                                    .font(.system(size: DeviceSize.fontSize(base: 16)))
                                    .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255).opacity(0.7))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, DeviceSize.padding(base: 16))
                    
                    // Add to Cart Button
                    Button(action: {
                        cartViewModel.addProductToCart(resolvedProduct, quantity: quantity)
                        navigationCoordinator.navigate(to: .cart)
                    }) {
                        HStack {
                            Image(systemName: "cart.badge.plus")
                            Text("Add to Cart")
                                .font(.system(size: DeviceSize.fontSize(base: 18), weight: .semibold))
                        }
                        .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DeviceSize.padding(base: 16))
                        .background(
                            LinearGradient(
                                colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.top, DeviceSize.padding(base: 24))

                    if isLoadingDetails {
                        ProgressView("Loading details...")
                            .tint(.cyan)
                            .foregroundColor(.white)
                    }
                }
                .padding(DeviceSize.padding(base: 24))
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 15/255, green: 23/255, blue: 42/255),
                    Color(red: 30/255, green: 41/255, blue: 59/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea(edges: .top)
        .task(id: product.id) {
            await loadDetails()
        }
    }

    @MainActor
    private func loadDetails() async {
        isLoadingDetails = true
        defer { isLoadingDetails = false }
        guard let url = APIEndpoints.url(path: APIEndpoints.Products.byId(product.id)) else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else { return }
            guard let raw = Self.extractObjectPayload(from: data) else { return }
            resolvedProduct = Self.mapProduct(from: raw, fallback: resolvedProduct)
        } catch {
            // Keep existing content if fetching details fails.
        }
    }

    private static func extractObjectPayload(from data: Data) -> [String: Any]? {
        guard let json = try? JSONSerialization.jsonObject(with: data) else { return nil }
        if let obj = json as? [String: Any] {
            if let nested = obj["data"] as? [String: Any] { return nested }
            if let nested = obj["item"] as? [String: Any] { return nested }
            return obj
        }
        return nil
    }

    private static func mapProduct(from raw: [String: Any], fallback: Product) -> Product {
        let id = int(from: raw["id"]) ?? int(from: raw["productId"]) ?? fallback.id
        let name = raw["name"] as? String ?? raw["title"] as? String ?? fallback.name
        let description = raw["description"] as? String
            ?? raw["shortDescription"] as? String
            ?? fallback.description
        let price = double(from: raw["price"]) ?? double(from: raw["unitPrice"]) ?? fallback.price
        let oldPrice = double(from: raw["oldPrice"]) ?? double(from: raw["originalPrice"]) ?? fallback.oldPrice
        let image = raw["img"] as? String ?? raw["image"] as? String ?? raw["imageUrl"] as? String ?? fallback.img
        let additionalInfo = raw["additionalInfo"] as? String ?? fallback.additionalInfo

        return Product(
            id: id,
            img: image,
            name: name,
            price: price,
            oldPrice: oldPrice,
            description: description,
            additionalInfo: additionalInfo,
            reviews: fallback.reviews,
            rating: fallback.rating
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

private struct ProductMetaChip: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Text("\(title):")
                .font(.system(size: DeviceSize.fontSize(base: 12), weight: .medium))
                .foregroundColor(Color(red: 148 / 255, green: 163 / 255, blue: 184 / 255))
            Text(value)
                .font(.system(size: DeviceSize.fontSize(base: 12), weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, DeviceSize.padding(base: 10))
        .padding(.vertical, DeviceSize.padding(base: 6))
        .background(Color(red: 15 / 255, green: 23 / 255, blue: 42 / 255).opacity(0.6))
        .cornerRadius(999)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: DeviceSize.fontSize(base: 16), weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? Color.cyan : Color(red: 203/255, green: 213/255, blue: 225/255))
                .frame(maxWidth: .infinity)
                .padding(.vertical, DeviceSize.padding(base: 12))
                .background(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(isSelected ? Color.cyan : Color.clear),
                    alignment: .bottom
                )
        }
    }
}

struct ReviewRow: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 8)) {
            HStack {
                Text(review.name)
                    .font(.system(size: DeviceSize.fontSize(base: 16), weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < review.rating ? "star.fill" : "star")
                            .font(.system(size: DeviceSize.fontSize(base: 12)))
                            .foregroundColor(index < review.rating ? .yellow : .gray)
                    }
                }
            }
            
            Text(review.comment)
                .font(.system(size: DeviceSize.fontSize(base: 14)))
                .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
        }
        .padding(DeviceSize.padding(base: 16))
        .background(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    ProductDetailsView(product: Product.sample)
        .environmentObject(CartViewModel())
        .environmentObject(NavigationCoordinator())
}
