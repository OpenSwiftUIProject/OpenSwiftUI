//
//  ColorNonDarwinShims.swift
//  OpenSwiftUICore

#if !canImport(CoreGraphics)
package import Foundation

/// A CGColor replacement in non-Darwin platform.
final package class NDColor: NSObject {
    package let red: CGFloat

    package let green: CGFloat

    package let blue: CGFloat

    package let alpha: CGFloat

    package init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

extension Color.Resolved {
    private static let cache: ObjectCache<Color.Resolved, NSObject> = ObjectCache { resolved in
        NDColor(
            red: CGFloat(resolved.red),
            green: CGFloat(resolved.green),
            blue: CGFloat(resolved.blue),
            alpha: CGFloat(resolved.opacity)
        )
    }

    package var kitColor: NSObject {
        Self.cache[self]
    }
}

#endif
