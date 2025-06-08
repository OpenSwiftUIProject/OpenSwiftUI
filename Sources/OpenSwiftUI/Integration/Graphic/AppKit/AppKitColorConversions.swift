//
//  AppKitColorConversions.swift
//  OpenSwiftUI
//
//  Status: Complete
//  ID: 7137BB7EE57FAC34F81DC437C151F7AB (SwiftUI)

#if canImport(AppKit)

public import OpenSwiftUICore
public import AppKit
import COpenSwiftUI

// MARK: - NSColor Conversions [6.5.4]

@available(iOS, unavailable)
@available(macOS, introduced: 10.15, deprecated: 100000.0, message: "Use Color(nsColor:) when converting a NSColor, or create a standard Color directly")
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension Color {
    /// Creates a color from an AppKit color.
    ///
    /// Use this method to create a SwiftUI color from an
    /// [NSColor](https://developer.apple.com/documentation/AppKit/NSColor) instance.
    /// The new color preserves the adaptability of the original.
    /// For example, you can create a rectangle using
    /// [linkColor](https://developer.apple.com/documentation/AppKit/NSColor/linkColor)
    /// to see how the shade adjusts to match the user's system settings:
    ///
    ///     struct Box: View {
    ///         var body: some View {
    ///             Color(NSColor.linkColor)
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
    ///   the left, and the dark variant on the right.](Color-init-4)
    ///
    /// > Note: Use this initializer only if you need to convert an existing
    /// [NSColor](https://developer.apple.com/documentation/AppKit/NSColor) to a
    /// SwiftUI color. Otherwise, create a OpenSwiftUI ``Color`` using an
    /// initializer like ``init(_:red:green:blue:opacity:)``, or use a system
    /// color like ``ShapeStyle/blue``.
    ///
    /// - Parameter color: An
    ///   [NSColor](https://developer.apple.com/documentation/AppKit/NSColor) instance
    ///   from which to create a color.
    @_disfavoredOverload
    nonisolated public init(_ color: NSColor) {
        self.init(nsColor: color)
    }
}

@available(OpenSwiftUI_v3_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension Color {
    /// Creates a color from an AppKit color.
    ///
    /// Use this method to create a SwiftUI color from an
    /// [NSColor](https://developer.apple.com/documentation/AppKit/NSColor) instance.
    /// The new color preserves the adaptability of the original.
    /// For example, you can create a rectangle using
    /// [linkColor](https://developer.apple.com/documentation/AppKit/NSColor/linkColor)
    /// to see how the shade adjusts to match the user's system settings:
    ///
    ///     struct Box: View {
    ///         var body: some View {
    ///             Color(nsColor: .linkColor)
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
    ///   the left, and the dark variant on the right.](Color-init-4)
    ///
    /// > Note: Use this initializer only if you need to convert an existing
    /// [NSColor](https://developer.apple.com/documentation/AppKit/NSColor) to a
    /// SwiftUI color. Otherwise, create a OpenSwiftUI ``Color`` using an
    /// initializer like ``init(_:red:green:blue:opacity:)``, or use a system
    /// color like ``ShapeStyle/blue``.
    ///
    /// - Parameter color: An
    ///   [NSColor](https://developer.apple.com/documentation/AppKit/NSColor) instance
    ///   from which to create a color.
    nonisolated public init(nsColor: NSColor) {
        self.init(provider: nsColor)
    }
}

private let dynamicColorCache: NSMapTable<ObjcColor, NSColor> = NSMapTable.strongToWeakObjects()

extension NSColor: ColorProvider {
    @available(OpenSwiftUI_v2_0, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    convenience public init(_ color: Color) {
        if let color = color.provider.as(NSColor.self) {
            self.init(color__openSwiftUI__: color)
        } else if let cgColor = color.provider.staticColor {
            self.init(cgColor: cgColor)!
        } else {
            let objCColor = ObjcColor(color)
            let cache = dynamicColorCache
            if let cachedColor = cache.object(forKey: objCColor) {
                self.init(color__openSwiftUI__: cachedColor)
            } else {
                self.init(name: nil) { appearance in
                    var environment = EnvironmentValues()
                    appearance.apply(to: &environment, vibrantBlendingStyle: ._1)
                    environment.allowsVibrantBlending = false
                    let resolved = color.resolve(in: environment)
                    return resolved.kitColor as! NSColor
                }
                cache.setObject(self, forKey: objCColor)
            }
        }
    }

    package func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        if _NSColorDependsOnAppearance(self) {
            return withColorAppearance(in: environment) {
                Color.Resolved(platformColor: self) ?? .clear
            }
        } else {
            return Color.Resolved(cgColor)
        }
    }

    private func withColorAppearance(in environment: EnvironmentValues, _ body: () -> Color.Resolved) -> Color.Resolved {
        let appearance = NSAppearance.appearance(from: environment, allowsVibrantBlending: false)
        var color = Color.Resolved.clear
        if let appearance {
            appearance.performAsCurrentDrawingAppearance {
                color = body()
            }
        } else {
            color = body()
        }
        return color
    }

    package var staticColor: CGColor? {
        if _NSColorDependsOnAppearance(self) {
            nil
        } else {
            cgColor
        }
    }
}

#endif
