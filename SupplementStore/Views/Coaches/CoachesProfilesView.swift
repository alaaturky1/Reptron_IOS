//
//  CoachesProfilesView.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI
import UIKit

// MARK: - Device Size Helper
// Local implementation of DeviceSize for CoachesProfilesView
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

struct CoachesProfilesView: View {
    let coach: Coach
    
    var body: some View {
        ScrollView {
            VStack(spacing: DeviceSize.spacing(base: 24)) {
                // Coach Header
                VStack(spacing: DeviceSize.spacing(base: 16)) {
                    APIReadyImageView(
                        imagePath: coach.image,
                        placeholderSystemName: "person.fill",
                        height: 150
                    )
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.cyan, lineWidth: 4))
                    
                    Text(coach.name)
                        .font(.system(size: DeviceSize.fontSize(base: 28), weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(coach.title)
                        .font(.system(size: DeviceSize.fontSize(base: 18)))
                        .foregroundColor(Color.cyan)
                }
                .padding(.top, DeviceSize.padding(base: 32))
                
                // Full Bio
                VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 16)) {
                    Text("About")
                        .font(.system(size: DeviceSize.fontSize(base: 24), weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(coach.fullBio)
                        .font(.system(size: DeviceSize.fontSize(base: 16)))
                        .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DeviceSize.padding(base: 24))
                .background(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.5))
                .cornerRadius(16)
                .padding(.horizontal, DeviceSize.padding(base: 16))
                
                // Stats Grid
                VStack(spacing: DeviceSize.spacing(base: 16)) {
                    StatRow(title: "Experience", value: coach.experience)
                    StatRow(title: "Clients", value: coach.clients)
                    StatRow(title: "Certifications", value: coach.certifications)
                    if let rate = coach.hourlyRate {
                        StatRow(title: "Hourly Rate", value: rate)
                    }
                }
                .padding(DeviceSize.padding(base: 24))
                .background(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.5))
                .cornerRadius(16)
                .padding(.horizontal, DeviceSize.padding(base: 16))
                
                // Contact
                VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 16)) {
                    Text("Contact")
                        .font(.system(size: DeviceSize.fontSize(base: 24), weight: .bold))
                        .foregroundColor(.white)
                    
                    InfoRow(icon: "phone.fill", text: coach.phone)
                    InfoRow(icon: "envelope.fill", text: coach.email)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DeviceSize.padding(base: 24))
                .background(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.5))
                .cornerRadius(16)
                .padding(.horizontal, DeviceSize.padding(base: 16))

                PageFooterView()
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

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: DeviceSize.fontSize(base: 16)))
                .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
            Spacer()
            Text(value)
                .font(.system(size: DeviceSize.fontSize(base: 16), weight: .bold))
                .foregroundColor(Color.cyan)
        }
    }
}

#Preview {
    CoachesProfilesView(coach: Coach.sample)
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
