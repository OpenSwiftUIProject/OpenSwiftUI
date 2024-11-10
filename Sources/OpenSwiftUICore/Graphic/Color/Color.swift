//
//  Color.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 3A792CB70CFCF892676D7ADF8BCA260F

import Foundation
#if canImport(Darwin)
public import CoreGraphics
#endif

/// A representation of a color that adapts to a given context.
///
/// You can create a color in one of several ways:
///
/// * Load a color from an Asset Catalog:
///     ```
///     let aqua = Color("aqua") // Looks in your app's main bundle by default.
///     ```
/// * Specify component values, like red, green, and blue; hue,
///   saturation, and brightness; or white level:
///     ```
///     let skyBlue = Color(red: 0.4627, green: 0.8392, blue: 1.0)
///     let lemonYellow = Color(hue: 0.1639, saturation: 1, brightness: 1)
///     let steelGray = Color(white: 0.4745)
///     ```
/// * Create a color instance from another color, like a
///   [UIColor](https://developer.apple.com/documentation/UIKit/UIColor) or an
///   [NSColor](https://developer.apple.com/documentation/AppKit/NSColor):
///     ```
///     #if os(iOS)
///     let linkColor = Color(uiColor: .link)
///     #elseif os(macOS)
///     let linkColor = Color(nsColor: .linkColor)
///     #endif
///     ```
/// * Use one of a palette of predefined colors, like ``ShapeStyle/black``,
///   ``ShapeStyle/green``, and ``ShapeStyle/purple``.
///
/// Some view modifiers can take a color as an argument. For example,
/// ``View/foregroundStyle(_:)`` uses the color you provide to set the
/// foreground color for view elements, like text or
/// [SF Symbols](https://developer.apple.com/documentation/design/human-interface-guidelines/sf-symbols):
///
///     Image(systemName: "leaf.fill")
///         .foregroundStyle(Color.green)
///
/// ![A screenshot of a green leaf.](Color-1)
///
/// Because SwiftUI treats colors as ``View`` instances, you can also
/// directly add them to a view hierarchy. For example, you can layer
/// a rectangle beneath a sun image using colors defined above:
///
///     ZStack {
///         skyBlue
///         Image(systemName: "sun.max.fill")
///             .foregroundStyle(lemonYellow)
///     }
///     .frame(width: 200, height: 100)
///
/// A color used as a view expands to fill all the space it's given,
/// as defined by the frame of the enclosing ``ZStack`` in the above example:
///
/// ![A screenshot of a yellow sun on a blue background.](Color-2)
///
/// OpenSwiftUI only resolves a color to a concrete value
/// just before using it in a given environment.
/// This enables a context-dependent appearance for
/// system defined colors, or those that you load from an Asset Catalog.
/// For example, a color can have distinct light and dark variants
/// that the system chooses from at render time.
@frozen
public struct Color {
//    package var provider: AnyColorBox
//    
//    package init(provider: AnyColorBox) {
//        self.provider = provider
//    }
//    
//    package init<P>(provider: P) where P: ColorProvider {
//        
//    }
}

extension Color {
    public func _apply(to shape: _ShapeStyle_Shape) {
        // TODO
    }
}

// MARK: - Color + ColorSpace

extension Color {
    public enum RGBColorSpace: Sendable {
        case sRGB
        case sRGBLinear
        case displayP3
    }

    public init(_ colorSpace: RGBColorSpace = .sRGB, red: Double, green: Double, blue: Double, opacity: Double = 1) {
        // self.init(red: red, green: green, blue: blue, opacity: opacity)
    }

    public init(_ colorSpace: RGBColorSpace = .sRGB, white: Double, opacity: Double = 1) {
    }

    public init(hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {

    }
}

package func HSBToRGB(hue: Double, saturation: Double, brightness: Double) -> (red: Double, green: Double, blue: Double) {
    fatalError("TODO")
}


extension Color.RGBColorSpace: Hashable {}
extension Color.RGBColorSpace: Equatable {}

#if canImport(Darwin)

// MARK: - CGColor + Color

extension Color {
    @available(*, deprecated, message: "Use Color(cgColor:) when converting a CGColor, or create a standard Color directly")
    public init(_ cgColor: CGColor) {
        self.init(cgColor: cgColor)
    }
}

extension Color {
    public init(cgColor: CGColor) {
//        ColorBox
    }
}

//extension CGColor: ColorProvider {
//    package func resolve(in environment: EnvironmentValues) -> <<error type>> {
//        <#code#>
//    }
//    
//    staticColor
//}

#endif


// MARK: - ColorProvider

package protocol ColorProvider: Hashable {
    func resolve(in environment: EnvironmentValues) -> Color.Resolved
    func apply(color: Color, to shape: inout _ShapeStyle_Shape)
    #if canImport(Darwin)
    var staticColor: CGColor? { get }
    #endif
    var kitColor: AnyObject? { get }
    var colorDescription: String { get }
    func opacity(at level: Int, environment: EnvironmentValues) -> Float
}

extension ColorProvider {
    #if canImport(Darwin)
    package var staticColor: CGColor? { nil }
    #endif
    package var kitColor: AnyObject? { nil }
    package var colorDescription: String { String(describing: self) }
    package func opacity(at level: Int, environment: EnvironmentValues) -> Float {
        fatalError("TODO")
    }
}

// MARK: - ColorBox

//private ColorBox<P> where P: ColorProvider {
//    let base: P
//}

@usableFromInline
package class AnyColorBox: AnyShapeStyleBox {
    
}


//private CustomColorProvider
