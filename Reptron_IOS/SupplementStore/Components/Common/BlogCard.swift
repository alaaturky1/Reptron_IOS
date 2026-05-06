//
//  BlogCard.swift
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

struct BlogCard: View {
    let image: String
    let title: String
    let date: String
    let onTap: () -> Void
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            VStack(spacing: 0) {
                // Image
                APIReadyImageView(
                    imagePath: image,
                    placeholderSystemName: "newspaper.fill",
                    height: 200
                )
                
                // Body
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.system(size: DeviceSize.fontSize(base: 20), weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(Color(red: 100/255, green: 116/255, blue: 139/255))
                            .font(.system(size: DeviceSize.fontSize(base: 14)))
                        
                        Text(date)
                            .font(.system(size: DeviceSize.fontSize(base: 14)))
                            .foregroundColor(Color(red: 100/255, green: 116/255, blue: 139/255))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DeviceSize.padding(base: 24))
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                    )
            )
            .overlay(
                VStack {
                    LinearGradient(
                        colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255), Color(red: 0, green: 151/255, blue: 167/255)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 4)
                    Spacer()
                }
                .cornerRadius(20, corners: [.topLeft, .topRight])
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

#Preview {
    BlogCard(
        image: "Nutrition",
        title: "Top 10 Healthiest Foods for Muscle Growth",
        date: "Feb 2025",
        onTap: {}
    )
    .frame(width: 300)
    .padding()
    .background(Color(red: 15/255, green: 23/255, blue: 42/255))
}
