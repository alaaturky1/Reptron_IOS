//
//  NotFoundView.swift
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

struct NotFoundView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: DeviceSize.spacing(base: 24)) {
            Spacer()
            
            // 404 Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color.cyan.opacity(0.5))
            
            Text("404")
                .font(.system(size: DeviceSize.fontSize(base: 72), weight: .heavy))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Page Not Found")
                .font(.system(size: DeviceSize.fontSize(base: 24), weight: .bold))
                .foregroundColor(.white)
            
            Text("The page you're looking for doesn't exist.")
                .font(.system(size: DeviceSize.fontSize(base: 16)))
                .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                .multilineTextAlignment(.center)
                .padding(.horizontal, DeviceSize.padding(base: 32))
            
            Button(action: {
                navigationCoordinator.navigateToRoot()
            }) {
                Text("Go Home")
                    .font(.system(size: DeviceSize.fontSize(base: 18), weight: .semibold))
                    .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                    .padding(.horizontal, DeviceSize.padding(base: 32))
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
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

#Preview {
    NotFoundView()
        .environmentObject(NavigationCoordinator())
}
