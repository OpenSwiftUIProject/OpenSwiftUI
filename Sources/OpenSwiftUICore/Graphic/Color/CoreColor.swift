//
//  CoreColor.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 4330A474F53D66045762501ED6F8A749 (SwiftUICore)

#if canImport(Darwin)
package import Foundation
import OpenSwiftUI_SPI

// MARK: - Color.Resolved + platformColor

extension Color.Resolved {
    package init?(platformColor: AnyObject) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        let result = CoreColorPlatformColorGetComponents(system: .defaults, color: platformColor, red: &red, green: &green, blue: &blue, alpha: &alpha)
        if result {
            self.init(red: Float(red), green: Float(green), blue: Float(blue), opacity: Float(alpha))
        } else {
            return nil
        }
    }

    private static let cache: ObjectCache<Color.Resolved, NSObject> = ObjectCache { resolved in
        CoreColor.platformColor(resolvedColor: resolved)!
    }
    
    package var kitColor: NSObject {
        Self.cache[self]
    }
}

extension CoreColor {
    package static func platformColor(resolvedColor: Color.Resolved) -> NSObject? {
        platformColor(red: CGFloat(resolvedColor.red), green: CGFloat(resolvedColor.green), blue: CGFloat(resolvedColor.blue), alpha: CGFloat(resolvedColor.opacity))
    }
    
    package static func platformColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> NSObject? {
        CorePlatformColorForRGBA(system: .defaults, red: red, green: green, blue: blue, alpha: alpha)
    }
}

#endif
