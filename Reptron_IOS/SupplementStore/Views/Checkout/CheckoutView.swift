//
//  CheckoutView.swift
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

struct CheckoutView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var purchaseViewModel: PurchaseViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var billingInfo = BillingInfo()
    @State private var paymentInfo = PaymentInfo()
    @State private var isLoading: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: DeviceSize.spacing(base: 24)) {
                // Header
                Text("Checkout")
                    .appSectionTitle()
                    .padding(.top, DeviceSize.padding(base: 32))
                
                // Billing Information
                VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 16)) {
                    Text("Billing Information")
                        .font(.system(size: DeviceSize.fontSize(base: 20), weight: .bold))
                        .foregroundColor(.white)
                    
                    CheckoutTextField(title: "Full Name", text: $billingInfo.name)
                    CheckoutTextField(title: "Email", text: $billingInfo.email, keyboardType: .emailAddress)
                    CheckoutTextField(title: "Address", text: $billingInfo.address)
                    CheckoutTextField(title: "City", text: $billingInfo.city)
                    CheckoutTextField(title: "Postal Code", text: $billingInfo.postalCode)
                    CheckoutTextField(title: "Country", text: $billingInfo.country)
                }
                .padding(DeviceSize.padding(base: 24))
                .appCardStyle()
                .padding(.horizontal, DeviceSize.padding(base: 16))
                
                // Payment Information
                VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 16)) {
                    Text("Payment Information")
                        .font(.system(size: DeviceSize.fontSize(base: 20), weight: .bold))
                        .foregroundColor(.white)
                    
                    CheckoutTextField(title: "Card Number", text: $paymentInfo.cardNumber, keyboardType: .numberPad)
                    CheckoutTextField(title: "Cardholder Name", text: $paymentInfo.cardName)
                    HStack(spacing: DeviceSize.spacing(base: 16)) {
                        CheckoutTextField(title: "Expiry (MM/YY)", text: $paymentInfo.expiry)
                        CheckoutTextField(title: "CVV", text: $paymentInfo.cvv, keyboardType: .numberPad)
                    }
                }
                .padding(DeviceSize.padding(base: 24))
                .appCardStyle()
                .padding(.horizontal, DeviceSize.padding(base: 16))
                
                // Order Summary
                VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 16)) {
                    Text("Order Summary")
                        .font(.system(size: DeviceSize.fontSize(base: 20), weight: .bold))
                        .foregroundColor(.white)
                    
                    ForEach(cartViewModel.cart) { item in
                        HStack {
                            Text("\(item.name) x\(item.quantity)")
                                .font(.system(size: DeviceSize.fontSize(base: 14)))
                                .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                            Spacer()
                            Text("$\(String(format: "%.2f", item.price * Double(item.quantity)))")
                                .font(.system(size: DeviceSize.fontSize(base: 14), weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Divider()
                        .background(Color.cyan.opacity(0.3))
                    
                    HStack {
                        Text("Total:")
                            .font(.system(size: DeviceSize.fontSize(base: 20), weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartViewModel.grandTotal))")
                            .font(.system(size: DeviceSize.fontSize(base: 24), weight: .heavy))
                            .foregroundColor(Color.cyan)
                    }
                }
                .padding(DeviceSize.padding(base: 24))
                .appCardStyle()
                .padding(.horizontal, DeviceSize.padding(base: 16))
                
                // Place Order Button
                Button(action: handlePlaceOrder) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Place Order")
                                .font(.system(size: DeviceSize.fontSize(base: 18), weight: .semibold))
                        }
                    }
                }
                .buttonStyle(PrimaryGlowButtonStyle())
                .disabled(isLoading || !isFormValid)
                .opacity((isLoading || !isFormValid) ? 0.6 : 1.0)
                .padding(.horizontal, DeviceSize.padding(base: 16))

                PageFooterView()
            }
        }
        .appScreenBackground()
    }
    
    private var isFormValid: Bool {
        !billingInfo.name.isEmpty &&
        !billingInfo.email.isEmpty &&
        !billingInfo.address.isEmpty &&
        !billingInfo.city.isEmpty &&
        !paymentInfo.cardNumber.isEmpty &&
        !paymentInfo.cardName.isEmpty
    }
    
    private func handlePlaceOrder() {
        isLoading = true
        
        // Create purchase order
        let shippingAddress = PurchaseOrder.ShippingAddress(
            name: billingInfo.name,
            address: billingInfo.address,
            city: billingInfo.city,
            postalCode: billingInfo.postalCode,
            country: billingInfo.country
        )
        
        let order = PurchaseOrder(
            items: cartViewModel.cart,
            total: cartViewModel.grandTotal,
            shippingAddress: shippingAddress
        )
        
        Task {
            do {
                try await purchaseViewModel.submitOrder(
                    shippingAddress: shippingAddress,
                    paymentMethod: "card"
                )
            } catch {
                // Keep local purchase behavior if API order creation fails.
            }
            
            await MainActor.run {
                purchaseViewModel.addPurchase(order)
                cartViewModel.clearCart()
                isLoading = false
                navigationCoordinator.navigate(to: .home)
            }
        }
    }
}

struct CheckoutTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 8)) {
            Text(title)
                .font(.system(size: DeviceSize.fontSize(base: 14), weight: .semibold))
                .foregroundColor(.white)
            
            TextField("Enter \(title.lowercased())", text: $text)
                .textFieldStyle(LoginTextFieldStyle())
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
        }
    }
}

#Preview {
    CheckoutView()
        .environmentObject(CartViewModel())
        .environmentObject(PurchaseViewModel())
        .environmentObject(NavigationCoordinator())
}
