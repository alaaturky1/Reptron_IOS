//
//  FeatureCard.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 50)
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(description)
                .font(.system(size: 15))
                .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    FeatureCard(
        icon: "star.fill",
        title: "Premium Quality",
        description: "Lab-tested ingredients"
    )
    .frame(width: 250)
    .padding()
    .background(Color(red: 15/255, green: 23/255, blue: 42/255))
}

