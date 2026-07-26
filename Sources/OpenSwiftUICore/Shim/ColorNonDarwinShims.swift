//
//  ColorNonDarwinShims.swift
//  OpenSwiftUICore

#if !canImport(CoreGraphics)
package import Foundation

/// A CGColor replacement in non-Darwin platform.
final package class NDColor: CFCompatObject {
    package let red: CGFloat

    package let green: CGFloat

    package let blue: CGFloat

    package let alpha: CGFloat

    package init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        super.init()
    }

    package override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? NDColor else { return false }
        return other.red == red
            && other.green == green
            && other.blue == blue
            && other.alpha == alpha
    }

    package override var hash: Int {
        var hasher = Hasher()
        hasher.combine(red)
        hasher.combine(green)
        hasher.combine(blue)
        hasher.combine(alpha)
        return hasher.finalize()
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
