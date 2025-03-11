//
//  UIKitConversions.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 6DC24D5146AF4B80347A1025025F68EE (SwiftUI)

#if canImport(UIKit)

public import OpenSwiftUICore
public import UIKit
import COpenSwiftUI

// MARK: - UIColor Conversions

@available(*, deprecated, message: "Use Color(uiColor:) when converting a UIColor, or create a standard Color directly")
@available(macOS, unavailable)
extension Color {
    /// Creates a color from a UIKit color.
    ///
    /// Use this method to create a SwiftUI color from a
    /// [UIColor](https://developer.apple.com/documentation/UIKit/UIColor) instance.
    /// The new color preserves the adaptability of the original.
    /// For example, you can create a rectangle using
    /// [link](https://developer.apple.com/documentation/uikit/uicolor/3173132-link)
    /// to see how the shade adjusts to match the user's system settings:
    ///
    ///     struct Box: View {
    ///         var body: some View {
    ///             Color(UIColor.link)
    ///                 .frame(width: 200, height: 100)
    ///         }
    ///     }
    ///
    /// The `Box` view defined above automatically changes its
    /// appearance when the user turns on Dark Mode. With the light and dark
    /// appearances placed side by side, you can see the subtle difference
    /// in shades:
    ///
    /// ![A side by side comparison of light and dark appearance screenshots of
    ///   rectangles rendered with the link color. The light variant appears on
    ///   the left, and the dark variant on the right.](Color-init-3)
    ///
    /// > Note: Use this initializer only if you need to convert an existing
    /// [UIColor](https://developer.apple.com/documentation/UIKit/UIColor) to a
    /// OpenSwiftUI color. Otherwise, create an OpenSwiftUI ``Color`` using an
    /// initializer like ``init(_:red:green:blue:opacity:)``, or use a system
    /// color like ``ShapeStyle/blue``.
    ///
    /// - Parameter color: A
    ///   [UIColor](https://developer.apple.com/documentation/UIKit/UIColor) instance
    ///   from which to create a color.
    @_disfavoredOverload
    public init(_ color: UIColor) {
        self.init(uiColor: color)
    }
}

@available(macOS, unavailable)
extension Color {
    /// Creates a color from a UIKit color.
    ///
    /// Use this method to create a SwiftUI color from a
    /// [UIColor](https://developer.apple.com/documentation/UIKit/UIColor) instance.
    /// The new color preserves the adaptability of the original.
    /// For example, you can create a rectangle using
    /// [link](https://developer.apple.com/documentation/uikit/uicolor/3173132-link)
    /// to see how the shade adjusts to match the user's system settings:
    ///
    ///     struct Box: View {
    ///         var body: some View {
    ///             Color(UIColor.link)
    ///                 .frame(width: 200, height: 100)
    ///         }
    ///     }
    ///
    /// The `Box` view defined above automatically changes its
    /// appearance when the user turns on Dark Mode. With the light and dark
    /// appearances placed side by side, you can see the subtle difference
    /// in shades:
    ///
    /// ![A side by side comparison of light and dark appearance screenshots of
    ///   rectangles rendered with the link color. The light variant appears on
    ///   the left, and the dark variant on the right.](Color-init-3)
    ///
    /// > Note: Use this initializer only if you need to convert an existing
    /// [UIColor](https://developer.apple.com/documentation/UIKit/UIColor) to a
    /// OpenSwiftUI color. Otherwise, create an OpenSwiftUI ``Color`` using an
    /// initializer like ``init(_:red:green:blue:opacity:)``, or use a system
    /// color like ``ShapeStyle/blue``.
    ///
    /// - Parameter color: A
    ///   [UIColor](https://developer.apple.com/documentation/UIKit/UIColor) instance
    ///   from which to create a color.
    public init(uiColor: UIColor) {
        self.init(provider: uiColor)
    }
}

extension UIColor: ColorProvider {
    private static var dynamicColorCache: NSMapTable<ObjcColor, UIColor> = NSMapTable.strongToWeakObjects()
    
    @available(macOS, unavailable)
    convenience public init(_ color: Color) {
        if let cgColor = color.provider.staticColor {
            self.init(cgColor: cgColor)
        } else {
            let objCColor = ObjcColor(color)
            let cache = Self.dynamicColorCache
            if let color = cache.object(forKey: objCColor) {
                self.init(color__openSwiftUI__: color)
            } else {
                let value: UIColor
                if let kitColor = color.provider.kitColor {
                    value = kitColor as! UIColor
                } else {
                    value = UIColor { trait in
                        // TODO: trait
                        let resolved = Color.Resolved.clear
                        return resolved.kitColor as! UIColor
                    }
                }
                self.init(color__openSwiftUI__: value)
                cache.setObject(value, forKey: objCColor)
            }
        }
    }
    
    package func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        if _UIColorDependsOnTraitCollection(self) {
            let trait = UITraitCollection.current.byOverriding(with: environment, viewPhase: .init(), focusedValues: .init())
            let color = resolvedColor(with: trait)
            return Color.Resolved(platformColor: color) ?? .clear
        } else {
            return Color.Resolved(cgColor)
        }
    }
    
    package var staticColor: CGColor? {
        if _UIColorDependsOnTraitCollection(self) {
            nil
        } else {
            cgColor
        }
    }
}

// MARK: - UIUserInterfaceStyle Conversions

extension ColorScheme {
    /// Creates a color scheme from its user interface style equivalent.
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init?(_ uiUserInterfaceStyle: UIUserInterfaceStyle) {
        switch uiUserInterfaceStyle {
            case .unspecified: return nil
            case .light: self = .light
            case .dark: self = .dark
            @unknown default: return nil
        }
    }
}

extension UIUserInterfaceStyle {
    /// Creates a user interface style from its ColorScheme equivalent.
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init(_ colorScheme: ColorScheme?) {
        switch colorScheme {
            case .light: self = .light
            case .dark: self = .dark
            case nil: self = .unspecified
        }
    }
}

// MARK: - UIAccessibilityContrast Conversions [TODO]

// ColorSchemeContrast
// UIAccessibilityContrast

// MARK: - UIContentSizeCategory Conversions [WIP]

extension DynamicTypeSize {
    /// Create a Dynamic Type size from its `UIContentSizeCategory` equivalent.
    public init?(_ uiSizeCategory: UIContentSizeCategory) {
        switch uiSizeCategory {
        case .extraSmall: self = .xSmall
        case .small: self = .small
        case .medium: self = .medium
        case .large: self = .large
        case .extraLarge: self = .xLarge
        case .extraExtraLarge: self = .xxLarge
        case .extraExtraExtraLarge: self = .xxxLarge
        case .accessibilityMedium: self = .accessibility1
        case .accessibilityLarge: self = .accessibility2
        case .accessibilityExtraLarge: self = .accessibility3
        case .accessibilityExtraExtraLarge: self = .accessibility4
        case .accessibilityExtraExtraExtraLarge: self = .accessibility5
        default: return nil
        }
    }
}

#endif
