//
//  WorkoutCard.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

struct WorkoutCard: View {
    let image: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Image
            APIReadyImageView(
                imagePath: image,
                placeholderSystemName: "figure.strengthtraining.traditional",
                height: 200
            )
            
            // Body
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
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
    }
}

#Preview {
    WorkoutCard(
        image: "Strength Training",
        title: "Strength Training",
        description: "Build maximum muscle and increase explosive power."
    )
    .frame(width: 300)
    .padding()
    .background(Color(red: 15/255, green: 23/255, blue: 42/255))
}

