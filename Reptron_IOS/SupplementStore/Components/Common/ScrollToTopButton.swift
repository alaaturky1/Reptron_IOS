//
//  ScrollToTopButton.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

struct ScrollToTopButton: View {
    @Binding var scrollOffset: CGFloat
    
    var body: some View {
        // Floating button to scroll to top
        Button(action: {
            // Scroll to top logic
        }) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.cyan)
        }
        .opacity(scrollOffset > 300 ? 1 : 0)
    }
}

#Preview {
    ScrollToTopButton(scrollOffset: .constant(500))
}

