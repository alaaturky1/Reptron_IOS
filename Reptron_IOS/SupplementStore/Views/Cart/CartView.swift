//
//  CartView.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI
import UIKit

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

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        ScrollView {
            VStack(spacing: DeviceSize.spacing(base: 24)) {
                // Header
                Text("Shopping Cart")
                    .appSectionTitle()
                    .padding(.top, DeviceSize.padding(base: 32))
                
                if cartViewModel.cart.isEmpty {
                    // Empty Cart
                    VStack(spacing: DeviceSize.spacing(base: 24)) {
                        Image(systemName: "cart")
                            .font(.system(size: 64))
                            .foregroundColor(Color.cyan.opacity(0.5))
                        
                        Text("Your cart is empty")
                            .font(.system(size: DeviceSize.fontSize(base: 24), weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Add some products to get started!")
                            .font(.system(size: DeviceSize.fontSize(base: 16)))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            navigationCoordinator.navigate(to: .store)
                        }) {
                            Text("Browse Store")
                        }
                        .buttonStyle(PrimaryGlowButtonStyle())
                        .padding(.top, DeviceSize.padding(base: 16))
                    }
                    .frame(maxWidth: .infinity, minHeight: 360)
                    .padding(.horizontal, DeviceSize.padding(base: 16))
                    .appCardStyle()
                    .padding(.vertical, DeviceSize.padding(base: 42))
                } else {
                    // Cart Items
                    VStack(spacing: DeviceSize.spacing(base: 16)) {
                        ForEach(cartViewModel.cart) { item in
                            CartItemRow(item: item)
                        }
                    }
                    .padding(.horizontal, DeviceSize.padding(base: 16))
                    
                    // Total Section
                    VStack(spacing: DeviceSize.spacing(base: 16)) {
                        HStack {
                            Text("Subtotal:")
                                .font(.system(size: DeviceSize.fontSize(base: 18)))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.2f", cartViewModel.grandTotal))")
                                .font(.system(size: DeviceSize.fontSize(base: 20), weight: .bold))
                                .foregroundColor(Color.cyan)
                        }
                        
                        Divider()
                            .background(Color.cyan.opacity(0.3))
                        
                        HStack {
                            Text("Total:")
                                .font(.system(size: DeviceSize.fontSize(base: 24), weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.2f", cartViewModel.grandTotal))")
                                .font(.system(size: DeviceSize.fontSize(base: 28), weight: .heavy))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                    }
                    .padding(DeviceSize.padding(base: 24))
                    .appCardStyle()
                    .padding(.horizontal, DeviceSize.padding(base: 16))
                    
                    // Checkout Button
                    Button(action: {
                        navigationCoordinator.navigate(to: .checkout)
                    }) {
                        Text("Proceed to Checkout")
                    }
                    .buttonStyle(PrimaryGlowButtonStyle())
                    .padding(.horizontal, DeviceSize.padding(base: 16))

                    PageFooterView()
                }
            }
        }
        .appScreenBackground()
    }
}

struct CartItemRow: View {
    let item: CartItemModel
    @EnvironmentObject var cartViewModel: CartViewModel
    
    var body: some View {
        HStack(spacing: DeviceSize.spacing(base: 16)) {
            // Product Image
            APIReadyImageView(
                imagePath: item.img,
                placeholderSystemName: "photo",
                height: 80
            )
            .frame(width: 80, height: 80)
            .cornerRadius(12)
            .clipped()
            
            // Product Info
            VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 8)) {
                Text(item.name)
                    .font(.system(size: DeviceSize.fontSize(base: 16), weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", item.price))")
                    .font(.system(size: DeviceSize.fontSize(base: 18), weight: .bold))
                    .foregroundColor(Color.cyan)
            }
            
            Spacer()
            
            // Quantity Controls
            VStack(spacing: DeviceSize.spacing(base: 8)) {
                HStack(spacing: DeviceSize.spacing(base: 12)) {
                    Button(action: {
                        cartViewModel.decreaseQuantity(item.lineId)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: DeviceSize.fontSize(base: 20)))
                            .foregroundColor(Color.cyan)
                    }
                    
                    Text("\(item.quantity)")
                        .font(.system(size: DeviceSize.fontSize(base: 18), weight: .bold))
                        .foregroundColor(.white)
                        .frame(minWidth: 30)
                    
                    Button(action: {
                        cartViewModel.incrementQuantity(item.lineId)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: DeviceSize.fontSize(base: 20)))
                            .foregroundColor(Color.cyan)
                    }
                }
                
                Text("$\(String(format: "%.2f", item.price * Double(item.quantity)))")
                    .font(.system(size: DeviceSize.fontSize(base: 14)))
                    .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
            }
            
            // Remove Button
            Button(action: {
                cartViewModel.removeFromCart(item.lineId)
            }) {
                Image(systemName: "trash.fill")
                    .font(.system(size: DeviceSize.fontSize(base: 18)))
                    .foregroundColor(.red)
            }
        }
        .padding(DeviceSize.padding(base: 16))
        .appCardStyle()
    }
}

#Preview {
    CartView()
        .environmentObject(CartViewModel())
        .environmentObject(NavigationCoordinator())
}
