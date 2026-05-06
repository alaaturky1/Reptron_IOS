//
//  CategoryButton.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

struct CategoryButton: View {
    let id: String
    let name: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.cyan.opacity(0.1)
                    }
                }
            )
            .foregroundColor(isSelected ? Color(red: 15/255, green: 23/255, blue: 42/255) : .cyan)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.cyan.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack {
        CategoryButton(
            id: "all",
            name: "All Products",
            icon: "bolt.fill",
            isSelected: true,
            action: {}
        )
        CategoryButton(
            id: "supplements",
            name: "Supplements",
            icon: "pills.fill",
            isSelected: false,
            action: {}
        )
    }
    .padding()
    .background(Color(red: 15/255, green: 23/255, blue: 42/255))
}

