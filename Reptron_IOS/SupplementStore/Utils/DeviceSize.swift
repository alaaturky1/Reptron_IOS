import SwiftUI
import UIKit

// MARK: - Device Size Helper
// Provides consistent spacing, padding, and font sizing across different device sizes
public enum DeviceSize {
    // Base values are for iPhone 12/13/14 (390x844 points)
    private static let baseScreenWidth: CGFloat = 390
    
    // Calculate a scaled value based on the current device width
    private static func scaleValue(_ value: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let scale = screenWidth / baseScreenWidth
        return value * scale
    }
    
    // MARK: - Spacing
    public static func spacing(base: CGFloat) -> CGFloat {
        return scaleValue(base)
    }
    
    // MARK: - Padding
    public static func padding(base: CGFloat) -> CGFloat {
        return scaleValue(base)
    }
    
    // MARK: - Font Size
    public static func fontSize(base: CGFloat) -> CGFloat {
        return scaleValue(base)
    }
    
    // MARK: - Corner Radius
    public static func cornerRadius(base: CGFloat) -> CGFloat {
        return scaleValue(base)
    }
}
