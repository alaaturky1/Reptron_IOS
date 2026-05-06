//
//  ProductCard.swift
//  SupplementStore
//
//  Created on [Date]
//
//  ProductCard component with backend-ready image placeholders.
//

import SwiftUI

struct ProductCard: View {
    let product: ProductCardStoreProduct
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Image Container
            VStack {
                APIReadyImageView(
                    imagePath: product.imagePath,
                    placeholderSystemName: "photo",
                    height: 180
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 2)
                )
            }
            .frame(minHeight: 220)
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.3))
            
            // Product Info
            VStack(spacing: 16) {
                // Product Name
                Text(product.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 56)
                    .frame(maxWidth: .infinity)
                
                // Price Container
                HStack(spacing: 16) {
                    // Current Price - Green with gradient text effect
                    Text("$\(String(format: "%.2f", product.price))")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(Color(red: 13/255, green: 228/255, blue: 13/255))
                    
                    // Old Price
                    if let oldPrice = product.oldPrice {
                        Text("$\(String(format: "%.2f", oldPrice))")
                            .font(.system(size: 19, weight: .regular))
                            .foregroundColor(Color(red: 235/255, green: 15/255, blue: 15/255))
                            .strikethrough()
                    }
                }
                
                // View Details Button
                Button(action: onTap) {
                    HStack(spacing: 12) {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 19))
                        Text("View Details")
                            .font(.system(size: 18, weight: .semibold))
                            .tracking(0.5)
                    }
                    .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .overlay(
                        // Shimmer effect overlay
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.clear, Color.white.opacity(0.2), Color.clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(0)
                    )
                }
                .buttonStyle(ProductCardButtonStyle())
            }
            .padding(24)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.8))
                .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
                .shadow(color: Color.cyan.opacity(0.1), radius: 50, x: 0, y: 0)
        )
        .overlay(
            // Top border gradient
            VStack {
                LinearGradient(
                    colors: [
                        Color.cyan,
                        Color(red: 0, green: 188/255, blue: 212/255),
                        Color(red: 0, green: 151/255, blue: 167/255)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 4)
                Spacer()
            }
            .cornerRadius(24, corners: [.topLeft, .topRight])
        )
        .overlay(
            // Inner glow effect
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.cyan.opacity(0.05), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
        )
    }
}

// Custom Button Style for hover effects
struct ProductCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(
                color: configuration.isPressed ? Color.clear : Color.cyan.opacity(0.4),
                radius: configuration.isPressed ? 0 : 10,
                x: 0,
                y: configuration.isPressed ? 0 : -2
            )
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// ProductCard-specific StoreProduct (adapter for ProductCard component)
// This matches the React Store product structure: { id, img, name, price, oldPrice }
struct ProductCardStoreProduct: Identifiable {
    let id: Int
    let imagePath: String?
    let name: String
    let price: Double
    let oldPrice: Double?
    
    // Initialize from Models/Product.swift StoreProduct
    init(from storeProduct: StoreProduct) {
        self.id = storeProduct.id
        self.imagePath = storeProduct.img
        self.name = storeProduct.name
        self.price = storeProduct.price
        self.oldPrice = storeProduct.oldPrice
    }
    
    // Initialize from Models/HomeProduct.swift HomeProduct
    init(from homeProduct: HomeProduct) {
        self.id = homeProduct.id
        self.imagePath = homeProduct.image
        self.name = homeProduct.name
        self.price = homeProduct.price
        self.oldPrice = homeProduct.originalPrice
    }
    
    // Direct initializer
    init(id: Int, imagePath: String?, name: String, price: Double, oldPrice: Double?) {
        self.id = id
        self.imagePath = imagePath
        self.name = name
        self.price = price
        self.oldPrice = oldPrice
    }
}

// Extension for rounded corners on specific sides
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ZStack {
        // Background matching the store
        LinearGradient(
            colors: [
                Color(red: 15/255, green: 23/255, blue: 42/255),
                Color(red: 30/255, green: 41/255, blue: 59/255),
                Color(red: 15/255, green: 23/255, blue: 42/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        ProductCard(
            product: ProductCardStoreProduct(
                id: 1,
                imagePath: nil,
                name: "Product Name",
                price: 0,
                oldPrice: nil
            ),
            onTap: {}
        )
        .frame(width: 300)
        .padding()
    }
}
