//
//  CoachDetailsView.swift
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

struct CoachDetailsView: View {
    let coach: Coach
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: DeviceSize.spacing(base: 24)) {
                // Coach Image
                APIReadyImageView(
                    imagePath: coach.image,
                    placeholderSystemName: "person.fill",
                    height: 300
                )
                .frame(maxWidth: .infinity)
                
                VStack(spacing: DeviceSize.spacing(base: 24)) {
                    // Coach Info
                    VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 12)) {
                        Text(coach.name)
                            .font(.system(size: DeviceSize.fontSize(base: 28), weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(coach.title)
                            .font(.system(size: DeviceSize.fontSize(base: 18)))
                            .foregroundColor(Color.cyan)
                        
                        Text(coach.fullBio)
                            .font(.system(size: DeviceSize.fontSize(base: 16)))
                            .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                            .padding(.top, DeviceSize.padding(base: 8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Stats
                    HStack(spacing: DeviceSize.spacing(base: 24)) {
                        StatItem(title: "Experience", value: coach.experience)
                        StatItem(title: "Clients", value: coach.clients)
                        StatItem(title: "Certifications", value: coach.certifications)
                    }
                    
                    // Contact Info
                    VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 12)) {
                        Text("Contact Information")
                            .font(.system(size: DeviceSize.fontSize(base: 20), weight: .bold))
                            .foregroundColor(.white)
                        
                        InfoRow(icon: "phone.fill", text: coach.phone)
                        InfoRow(icon: "envelope.fill", text: coach.email)
                        if let rate = coach.hourlyRate {
                            InfoRow(icon: "dollarsign.circle.fill", text: rate)
                        }
                    }
                    .padding(DeviceSize.padding(base: 20))
                    .background(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.5))
                    .cornerRadius(16)
                    
                    // View Profile Button
                    Button(action: {
                        navigationCoordinator.navigate(to: .coachesProfiles(id: coach.id))
                    }) {
                        Text("View Full Profile")
                            .font(.system(size: DeviceSize.fontSize(base: 18), weight: .semibold))
                            .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .frame(maxWidth: .infinity)
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
                }
                .padding(DeviceSize.padding(base: 24))

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
        .ignoresSafeArea(edges: .top)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: DeviceSize.spacing(base: 4)) {
            Text(value)
                .font(.system(size: DeviceSize.fontSize(base: 20), weight: .bold))
                .foregroundColor(Color.cyan)
            Text(title)
                .font(.system(size: DeviceSize.fontSize(base: 12)))
                .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
        }
        .frame(maxWidth: .infinity)
        .padding(DeviceSize.padding(base: 16))
        .background(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.5))
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: DeviceSize.spacing(base: 12)) {
            Image(systemName: icon)
                .foregroundColor(Color.cyan)
                .frame(width: 24)
            Text(text)
                .font(.system(size: DeviceSize.fontSize(base: 16)))
                .foregroundColor(.white)
            Spacer()
        }
    }
}

#Preview {
    CoachDetailsView(coach: Coach.sample)
        .environmentObject(NavigationCoordinator())
}
