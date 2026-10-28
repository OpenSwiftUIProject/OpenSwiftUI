//
//  AnyGradient.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 50251084C79137239112ABA67F1FABAC (SwiftUICore)

public import Foundation

/// A color gradient.
///
/// When used as a ``ShapeStyle``, this type draws a linear gradient
/// with start-point [0.5, 0] and end-point [0.5, 1].
@available(OpenSwiftUI_v4_0, *)
@frozen
public struct AnyGradient: Hashable, ShapeStyle, Sendable {
    package var provider: AnyGradientBox

    package init(box: AnyGradientBox) {
        provider = box
    }

    package init<P>(provider: P) where P: GradientProvider {
        self.provider = GradientBox(base: provider)
    }

    /// Creates a new instance from the specified gradient.
    public init(_ gradient: Gradient) {
        self.init(provider: gradient)
    }

    package func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        provider.resolve(in: environment)
    }

    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        provider.fallbackColor(in: environment)
    }

    public func _apply(to shape: inout _ShapeStyle_Shape) {
        _AnyLinearGradient(
            gradient: self,
            startPoint: .top,
            endPoint: .bottom
        )._apply(to: &shape)
    }

    public func hash(into hasher: inout Hasher) {
        provider.hash(into: &hasher)
    }

    public static func == (lhs: AnyGradient, rhs: AnyGradient) -> Bool {
        lhs.provider === rhs.provider || lhs.provider.isEqual(to: rhs.provider)
    }
}

package protocol GradientProvider: Hashable {
    func resolve(in environment: EnvironmentValues) -> ResolvedGradient
    func fallbackColor(in environment: EnvironmentValues) -> Color?
}

extension GradientProvider {
    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        nil
    }
}

extension Gradient: GradientProvider {}

@usableFromInline
package class AnyGradientBox: AnyShapeStyleBox, @unchecked Sendable {
    override package final func apply(to shape: inout _ShapeStyle_Shape) {
        AnyGradient(box: self)._apply(to: &shape)
    }

    package func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        _openSwiftUIBaseClassAbstractMethod()
    }

    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        _openSwiftUIBaseClassAbstractMethod()
    }

    package func hash(into hasher: inout Hasher) {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

private final class GradientBox<P>: AnyGradientBox, @unchecked Sendable where P: GradientProvider {
    let base: P

    init(base: P) {
        self.base = base
    }

    override func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        base.resolve(in: environment)
    }

    override func fallbackColor(in environment: EnvironmentValues) -> Color? {
        base.fallbackColor(in: environment)
    }

    override func isEqual(to other: AnyShapeStyleBox) -> Bool {
        guard let other = other as? GradientBox<P> else { return false }
        return base == other.base
    }

    override func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }
}

// MARK: - ShapeStyle + LinearGradient (AnyGradient)

@available(OpenSwiftUI_v4_0, *)
extension ShapeStyle where Self == LinearGradient {
    /// A linear gradient.
    ///
    /// The gradient applies the color function along an axis, as
    /// defined by its start and end points. The gradient maps the unit
    /// space points into the bounding rectangle of each shape filled
    /// with the gradient.
    ///
    /// For example, a linear gradient used as a background:
    ///
    ///     ContentView()
    ///         .background(.linearGradient(.red.gradient,
    ///             startPoint: .top, endPoint: .bottom))
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static func linearGradient(
        _ gradient: AnyGradient,
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) -> some ShapeStyle {
        _AnyLinearGradient(
            gradient: gradient,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

// MARK: - ShapeStyle + RadialGradient (AnyGradient)

@available(OpenSwiftUI_v4_0, *)
extension ShapeStyle where Self == RadialGradient {
    /// A radial gradient.
    ///
    /// The gradient applies the color function as the distance from a
    /// center point, scaled to fit within the defined start and end
    /// radii. The gradient maps the unit space center point into the
    /// bounding rectangle of each shape filled with the gradient.
    ///
    /// For example, a radial gradient used as a background:
    ///
    ///     ContentView()
    ///         .background(.radialGradient(.red.gradient, endRadius: 100))
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static func radialGradient(
        _ gradient: AnyGradient,
        center: UnitPoint = .center,
        startRadius: CGFloat = 0,
        endRadius: CGFloat
    ) -> some ShapeStyle {
        _AnyRadialGradient(
            gradient: gradient,
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }
}

// MARK: - ShapeStyle + EllipticalGradient (AnyGradient)

@available(OpenSwiftUI_v4_0, *)
extension ShapeStyle where Self == EllipticalGradient {
    /// A radial gradient that draws an ellipse.
    ///
    /// The gradient maps its coordinate space to the unit space square
    /// in which its center and radii are defined, then stretches that
    /// square to fill its bounding rect, possibly also stretching the
    /// circular gradient to have elliptical contours.
    ///
    /// For example, an elliptical gradient used as a background:
    ///
    ///     ContentView()
    ///         .background(.ellipticalGradient(.red.gradient))
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static func ellipticalGradient(
        _ gradient: AnyGradient,
        center: UnitPoint = .center,
        startRadiusFraction: CGFloat = 0,
        endRadiusFraction: CGFloat = 0.5
    ) -> some ShapeStyle {
        _AnyEllipticalGradient(
            gradient: gradient,
            center: center,
            startRadiusFraction: startRadiusFraction,
            endRadiusFraction: endRadiusFraction
        )
    }
}

// MARK: - ShapeStyle + AngularGradient (AnyGradient)

@available(OpenSwiftUI_v4_0, *)
extension ShapeStyle where Self == AngularGradient {
    /// An angular gradient, which applies the color function as the
    /// angle changes between the start and end angles, and anchored to
    /// a relative center point within the filled shape.
    ///
    /// An angular gradient is also known as a "conic" gradient. If
    /// `endAngle - startAngle > 2π`, the gradient only draws the last complete
    /// turn. If `endAngle - startAngle < 2π`, the gradient fills the missing
    /// area with the colors defined by gradient stop locations at `0` and `1`,
    /// transitioning between the two halfway across the missing area.
    ///
    /// For example, an angular gradient used as a background:
    ///
    ///     ContentView()
    ///         .background(.angularGradient(
    ///             .red.gradient,
    ///             startAngle: .zero, endAngle: .degrees(180)))
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    ///
    /// - Parameters:
    ///   - gradient: The gradient to use for filling the shape, providing the
    ///     colors and their relative stop locations.
    ///   - center: The relative center of the gradient, mapped from the unit
    ///     space into the bounding rectangle of the filled shape.
    ///   - startAngle: The angle that marks the beginning of the gradient.
    ///   - endAngle: The angle that marks the end of the gradient.
    @_alwaysEmitIntoClient
    public static func angularGradient(
        _ gradient: AnyGradient,
        center: UnitPoint = .center,
        startAngle: Angle,
        endAngle: Angle
    ) -> some ShapeStyle {
        _AnyAngularGradient(
            gradient: gradient,
            center: center,
            startAngle: startAngle,
            endAngle: endAngle
        )
    }

    /// A conic gradient that completes a full turn, optionally starting from
    /// a given angle and anchored to a relative center point within the filled
    /// shape.
    ///
    /// For example, a conic gradient used as a background:
    ///
    ///     let gradient = AnyGradient(Gradient(colors: [.red, .yellow]))
    ///
    ///     ContentView()
    ///         .background(.conicGradient(gradient))
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    ///
    /// - Parameters:
    ///   - gradient: The gradient to use for filling the shape, providing the
    ///     colors and their relative stop locations.
    ///   - center: The relative center of the gradient, mapped from the unit
    ///     space into the bounding rectangle of the filled shape.
    ///   - angle: The angle to offset the beginning of the gradient's full
    ///     turn.
    @_alwaysEmitIntoClient
    public static func conicGradient(
        _ gradient: AnyGradient,
        center: UnitPoint = .center,
        angle: Angle = .zero
    ) -> some ShapeStyle {
        _AnyAngularGradient(
            gradient: gradient,
            center: center,
            startAngle: angle,
            endAngle: angle + .radians(2 * .pi)
        )
    }
}

// MARK: - _AnyLinearGradient

@available(OpenSwiftUI_v4_0, *)
@frozen
public struct _AnyLinearGradient: Paint {
    @usableFromInline var gradient: AnyGradient
    @usableFromInline var startPoint: UnitPoint
    @usableFromInline var endPoint: UnitPoint

    @inlinable
    init(gradient: AnyGradient, startPoint: UnitPoint, endPoint: UnitPoint) {
        self.gradient = gradient
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    func resolvePaint(in environment: EnvironmentValues) -> LinearGradient._Paint {
        LinearGradient._Paint(
            gradient: gradient.resolve(in: environment),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    func fallbackColor(in environment: EnvironmentValues) -> Color? {
        gradient.fallbackColor(in: environment)
    }
}

// MARK: - _AnyRadialGradient

@available(OpenSwiftUI_v4_0, *)
@frozen
public struct _AnyRadialGradient: Paint {
    @usableFromInline var gradient: AnyGradient
    @usableFromInline var center: UnitPoint
    @usableFromInline var startRadius: CGFloat
    @usableFromInline var endRadius: CGFloat

    @inlinable
    init(
        gradient: AnyGradient,
        center: UnitPoint,
        startRadius: CGFloat,
        endRadius: CGFloat
    ) {
        self.gradient = gradient
        self.center = center
        self.startRadius = startRadius
        self.endRadius = endRadius
    }

    func resolvePaint(in environment: EnvironmentValues) -> RadialGradient._Paint {
        RadialGradient._Paint(
            gradient: gradient.resolve(in: environment),
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }

    func fallbackColor(in environment: EnvironmentValues) -> Color? {
        gradient.fallbackColor(in: environment)
    }
}

// MARK: - _AnyEllipticalGradient

@available(OpenSwiftUI_v4_0, *)
@frozen
public struct _AnyEllipticalGradient: Paint {
    @usableFromInline var gradient: AnyGradient
    @usableFromInline var center: UnitPoint
    @usableFromInline var startRadiusFraction: CGFloat
    @usableFromInline var endRadiusFraction: CGFloat

    @inlinable
    init(
        gradient: AnyGradient,
        center: UnitPoint = .center,
        startRadiusFraction: CGFloat,
        endRadiusFraction: CGFloat
    ) {
        self.gradient = gradient
        self.center = center
        self.startRadiusFraction = startRadiusFraction
        self.endRadiusFraction = endRadiusFraction
    }

    func resolvePaint(in environment: EnvironmentValues) -> EllipticalGradient._Paint {
        EllipticalGradient._Paint(
            gradient: gradient.resolve(in: environment),
            center: center,
            startRadiusFraction: startRadiusFraction,
            endRadiusFraction: endRadiusFraction
        )
    }

    func fallbackColor(in environment: EnvironmentValues) -> Color? {
        gradient.fallbackColor(in: environment)
    }
}

// MARK: - _AnyAngularGradient

@available(OpenSwiftUI_v4_0, *)
@frozen
public struct _AnyAngularGradient: Paint {
    @usableFromInline var gradient: AnyGradient
    @usableFromInline var center: UnitPoint
    @usableFromInline var startAngle: Angle
    @usableFromInline var endAngle: Angle

    @inlinable
    init(
        gradient: AnyGradient,
        center: UnitPoint,
        startAngle: Angle,
        endAngle: Angle
    ) {
        self.gradient = gradient
        self.center = center
        self.startAngle = startAngle
        self.endAngle = endAngle
    }

    func resolvePaint(in environment: EnvironmentValues) -> AngularGradient._Paint {
        AngularGradient._Paint(
            gradient: gradient.resolve(in: environment),
            center: center,
            startAngle: startAngle,
            endAngle: endAngle
        )
    }

    func fallbackColor(in environment: EnvironmentValues) -> Color? {
        gradient.fallbackColor(in: environment)
    }
}

// MARK: - EitherGradient

package enum EitherGradient: Hashable {
    case gradient(Gradient)
    case anyGradient(AnyGradient)

    package func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        switch self {
        case let .gradient(gradient):
            gradient.resolve(in: environment)
        case let .anyGradient(gradient):
            gradient.resolve(in: environment)
        }
    }

    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        switch self {
        case let .gradient(gradient):
            gradient.fallbackColor(in: environment)
        case let .anyGradient(gradient):
            gradient.fallbackColor(in: environment)
        }
    }

    package var constantColor: Color? {
        switch self {
        case let .gradient(gradient):
            gradient.constantColor
        case .anyGradient:
            nil
        }
    }
}
