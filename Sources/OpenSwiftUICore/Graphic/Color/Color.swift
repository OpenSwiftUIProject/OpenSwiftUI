//
//  Color.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 3A792CB70CFCF892676D7ADF8BCA260F (SwiftUICore)

import Foundation
#if canImport(Darwin)
public import CoreGraphics
#endif

// MARK: - Color

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
/// Because OpenSwiftUI treats colors as ``View`` instances, you can also
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
public struct Color: Hashable, CustomStringConvertible, Sendable {
    package var provider: AnyColorBox
    
    package init(box: AnyColorBox) {
        self.provider = box
    }
    
    package init<P>(provider: P) where P: ColorProvider {
        self.init(box: ColorBox(base: provider))
    }
    
    /// Creates a color that represents the specified custom color.
    public init<T>(_ color: T) where T: Hashable, T: ShapeStyle, T.Resolved == Color.Resolved {
        self.init(provider: CustomColorProvider(base: color))
    }
    
    /// Evaluates this color to a resolved color given the current
    /// `context`.
    public func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        provider.resolve(in: environment)
    }
    
    #if canImport(Darwin)
    /// A Core Graphics representation of the color, if available.
    ///
    /// You can get a
    /// [CGColor](https://developer.apple.com/documentation/CoreGraphics/CGColor)
    /// instance from a constant OpenSwiftUI color. This includes colors you create
    /// from a Core Graphics color, from RGB or HSB components, or from constant
    /// UIKit and AppKit colors.
    ///
    /// For a dynamic color, like one you load from an Asset Catalog using
    /// ``init(_:bundle:)``, or one you create from a dynamic UIKit or AppKit
    /// color, this property is `nil`. To evaluate all types of colors, use the
    /// `resolve(in:)` method.
    @available(*, deprecated, renamed: "resolve(in:)")
    public var cgColor: CoreGraphics.CGColor? {
        provider.staticColor
    }
    #endif
    
    /// Hashes the essential components of the color by feeding them into the
    /// given hash function.
    ///
    /// - Parameters:
    ///   - hasher: The hash function to use when combining the components of
    ///     the color.
    public func hash(into hasher: inout Hasher) {
        provider.hash(into: &hasher)
    }
    
    /// Indicates whether two colors are equal.
    ///
    /// - Parameters:
    ///   - lhs: The first color to compare.
    ///   - rhs: The second color to compare.
    /// - Returns: A Boolean that's set to `true` if the two colors are equal.
    public static func == (lhs: Color, rhs: Color) -> Bool {
        lhs.provider.isEqual(to: rhs.provider)
    }
    
    public var description: String {
        provider.description
    }
}

extension Color {
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        provider.apply(to: &shape)
    }
}

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
        environment.systemColorDefinition.base.opacity(at: level, environment: environment)
    }
}

// MARK: - Color + View

extension Color: EnvironmentalView, View {
    package func body(environment: EnvironmentValues) -> ColorView {
        ColorView(resolve(in: environment))
    }
    
    public typealias Body = Never
    
    package typealias EnvironmentBody = ColorView
}

// MARK: - AnyColorBox

@usableFromInline
package class AnyColorBox: AnyShapeStyleBox, @unchecked Sendable {
    override package final func apply(to shape: inout _ShapeStyle_Shape) {
        guard case let .fallbackColor(level) = shape.operation else {
            apply(color: Color(box: self), to: &shape)
            return
        }
        let color: Color
        if level >= 1 {
            let opacity = opacity(at: level, environment: shape.environment)
            color = Color(box: self).opacity(Double(opacity))
        } else {
            color = Color(box: self)
        }
        shape.result = .color(color)
    }

    package func resolve(in environment: EnvironmentValues) -> Color.Resolved { preconditionFailure("") }
    package func apply(color: Color, to shape: inout _ShapeStyle_Shape) { preconditionFailure("") }
    #if canImport(Darwin)
    package var staticColor: CGColor? { preconditionFailure("") }
    #endif
    package var kitColor: AnyObject? { preconditionFailure("") }
    package func hash(into hasher: inout Hasher) { preconditionFailure("") }
    package var description: String { preconditionFailure("") }
    package func opacity(at level: Int, environment: EnvironmentValues) -> Float { preconditionFailure("") }
}

@available(*, unavailable)
extension AnyColorBox : Sendable {}

// MARK: - ColorBox

private final class ColorBox<P>: AnyColorBox, @unchecked Sendable where P: ColorProvider {
    let base: P
    
    init(base: P) {
        self.base = base
    }
    
    override func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        base.resolve(in: environment)
    }
    
    override func apply(color: Color, to shape: inout _ShapeStyle_Shape) {
        base.apply(color: color, to: &shape)
    }
    
    #if canImport(Darwin)
    override var staticColor: CGColor? {
        base.staticColor
    }
    #endif
    
    override var kitColor: AnyObject? {
        base.kitColor
    }
    
    override func isEqual(to other: AnyShapeStyleBox) -> Bool {
        guard let other = other as? ColorBox<P> else { return false }
        return base == other.base
    }
    
    override func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }
    
    override var description: String {
        base.colorDescription
    }
    
    override func opacity(at level: Int, environment: EnvironmentValues) -> Float {
        base.opacity(at: level, environment: environment)
    }
}

#if canImport(Darwin)

// MARK: - ObjcColor

@objc
final package class ObjcColor: NSObject {
    package let color: Color
    
    package init(_ color: Color) {
        self.color = color
        super.init()
    }
    
    @objc
    override package func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ObjcColor else { return false }
        return color == other.color
    }

    @objc
    override package var hash: Int {
        var hasher = Hasher()
        color.hash(into: &hasher)
        return hasher.finalize()
    }
}

#endif

// MARK: - CustomColorProvider

private struct CustomColorProvider<P>: ColorProvider where P: Hashable, P: ShapeStyle, P.Resolved == Color.Resolved {
    let base: P
    
    func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        base.resolve(in: environment)
    }
    
    var colorDescription: String {
        String(describing: base)
    }
}
