//
//  MyPurchasesView.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

struct MyPurchasesView: View {
    @EnvironmentObject var purchaseViewModel: PurchaseViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("My Purchases")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.top, 32)
                
                if purchaseViewModel.purchases.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "bag")
                            .font(.system(size: 64))
                            .foregroundColor(Color.cyan.opacity(0.5))
                        
                        Text("No purchases yet")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Your order history will appear here")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                    }
                    .padding(.vertical, 64)
                } else {
                    // Purchase List
                    ForEach(purchaseViewModel.purchasesReversed) { purchase in
                        PurchaseCard(purchase: purchase)
                    }
                    .padding(.horizontal, 16)
                }
                
                Color.clear
                    .frame(height: 200)
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
    }
}

struct PurchaseCard: View {
    let purchase: PurchaseOrder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Order Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(purchase.id)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(purchase.date)
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                }
                
                Spacer()
                
                Text("$\(String(format: "%.2f", purchase.total))")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.cyan)
            }
            
            Divider()
                .background(Color.cyan.opacity(0.3))
            
            // Items
            VStack(alignment: .leading, spacing: 8) {
                ForEach(purchase.items) { item in
                    HStack {
                        Text("\(item.name) x\(item.quantity)")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                        Spacer()
                        Text("$\(String(format: "%.2f", item.price * Double(item.quantity)))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Shipping Address
            VStack(alignment: .leading, spacing: 4) {
                Text("Shipping to:")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                
                Text("\(purchase.shippingAddress.name)\n\(purchase.shippingAddress.address)\n\(purchase.shippingAddress.city), \(purchase.shippingAddress.postalCode)\n\(purchase.shippingAddress.country)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255).opacity(0.8))
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.5))
        .cornerRadius(16)
    }
}

#Preview {
    MyPurchasesView()
        .environmentObject(PurchaseViewModel())
}

