//
//  TestimonialCard.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

struct TestimonialCard: View {
    let testimonial: Testimonial
    
    var body: some View {
        VStack(spacing: 24) {
            // Profile Image
            APIReadyImageView(
                imagePath: testimonial.image,
                placeholderSystemName: "person.crop.circle.fill",
                height: 100
            )
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 3)
            )
            
            // Quote
            Text("\"\(testimonial.content)\"")
                .font(.system(size: 20))
                .italic()
                .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal)
            
            // Name
            Text(testimonial.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Role
            Text(testimonial.role)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
        }
        .frame(maxWidth: .infinity)
        .padding(48)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
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
            .cornerRadius(24, corners: [.topLeft, .topRight])
        )
    }
}

#Preview {
    TestimonialCard(
        testimonial: Testimonial(
            id: 1,
            name: "Alex Rodriguez",
            role: "Professional Athlete",
            content: "Reptron transformed my recovery and boosted performance.",
            image: "testimonial-2"
        )
    )
    .padding()
    .background(Color(red: 15/255, green: 23/255, blue: 42/255))
}

