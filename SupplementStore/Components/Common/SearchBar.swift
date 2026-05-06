//
//  SearchBar.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchTerm: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.cyan)
                .font(.system(size: 18))
                .padding(.leading, 16)
            
            TextField(placeholder, text: $searchTerm)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .padding(.vertical, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    SearchBar(searchTerm: .constant(""), placeholder: "Search products...")
        .padding()
        .background(Color(red: 15/255, green: 23/255, blue: 42/255))
}

