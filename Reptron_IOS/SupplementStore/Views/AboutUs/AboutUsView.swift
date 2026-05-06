//
//  AboutUsView.swift
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

struct AboutUsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DeviceSize.spacing(base: 32)) {
                // Header
                Text("About Us")
                    .appSectionTitle()
                    .padding(.top, DeviceSize.padding(base: 32))
                
                // Mission
                InfoSection(
                    title: "Our Mission",
                    content: "To provide premium supplements, elite equipment, and expert guidance to help you achieve your fitness goals and transform your health."
                )
                
                // Vision
                InfoSection(
                    title: "Our Vision",
                    content: "To be the leading destination for fitness enthusiasts, athletes, and health-conscious individuals seeking quality products and expert support."
                )
                
                // Values
                InfoSection(
                    title: "Our Values",
                    content: "Quality, Integrity, Innovation, and Customer Satisfaction are at the core of everything we do."
                )

                PageFooterView()
            }
            .padding(.horizontal, DeviceSize.padding(base: 24))
        }
        .appScreenBackground()
    }
}

struct InfoSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 12)) {
            Text(title)
                .font(.system(size: DeviceSize.fontSize(base: 24), weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(content)
                .font(.system(size: DeviceSize.fontSize(base: 16)))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DeviceSize.padding(base: 24))
        .appCardStyle()
    }
}

#Preview {
    AboutUsView()
}
