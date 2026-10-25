//
//  GradientStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

// MARK: - ShapeStyle + LinearGradient

@available(OpenSwiftUI_v1_0, *)
extension ShapeStyle where Self == LinearGradient {
    /// A linear gradient.
    ///
    /// The gradient applies the color function along an axis, as defined by its
    /// start and end points. The gradient maps the unit space points into the
    /// bounding rectangle of each shape filled with the gradient.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static func linearGradient(
        _ gradient: Gradient,
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) -> LinearGradient {
        .init(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
    }

    /// A linear gradient defined by a collection of colors.
    ///
    /// The gradient applies the color function along an axis, as defined by its
    /// start and end points. The gradient maps the unit space points into the
    /// bounding rectangle of each shape filled with the gradient.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static func linearGradient(
        colors: [Color],
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) -> LinearGradient {
        .init(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }

    /// A linear gradient defined by a collection of color stops.
    ///
    /// The gradient applies the color function along an axis, as defined by its
    /// start and end points. The gradient maps the unit space points into the
    /// bounding rectangle of each shape filled with the gradient.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static func linearGradient(
        stops: [Gradient.Stop],
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) -> LinearGradient {
        .init(stops: stops, startPoint: startPoint, endPoint: endPoint)
    }
}

// MARK: - ShapeStyle + RadialGradient

@available(OpenSwiftUI_v1_0, *)
extension ShapeStyle where Self == RadialGradient {
    /// A radial gradient.
    ///
    /// The gradient applies the color function as the distance from a center
    /// point, scaled to fit within the defined start and end radii. The
    /// gradient maps the unit space center point into the bounding rectangle of
    /// each shape filled with the gradient.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static func radialGradient(
        _ gradient: Gradient,
        center: UnitPoint,
        startRadius: CGFloat,
        endRadius: CGFloat
    ) -> RadialGradient {
        .init(
            gradient: gradient,
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }

    /// A radial gradient defined by a collection of colors.
    ///
    /// The gradient applies the color function as the distance from a center
    /// point, scaled to fit within the defined start and end radii. The
    /// gradient maps the unit space center point into the bounding rectangle of
    /// each shape filled with the gradient.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static func radialGradient(
        colors: [Color],
        center: UnitPoint,
        startRadius: CGFloat,
        endRadius: CGFloat
    ) -> RadialGradient {
        .init(
            colors: colors,
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }

    /// A radial gradient defined by a collection of color stops.
    ///
    /// The gradient applies the color function as the distance from a center
    /// point, scaled to fit within the defined start and end radii. The
    /// gradient maps the unit space center point into the bounding rectangle of
    /// each shape filled with the gradient.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static func radialGradient(
        stops: [Gradient.Stop],
        center: UnitPoint,
        startRadius: CGFloat,
        endRadius: CGFloat
    ) -> RadialGradient {
        .init(
            stops: stops,
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }
}

// MARK: - ShapeStyle + EllipticalGradient

@available(OpenSwiftUI_v3_0, *)
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
    ///     let gradient = Gradient(colors: [.red, .yellow])
    ///
    ///     ContentView()
    ///         .background(.ellipticalGradient(gradient))
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static func ellipticalGradient(
        _ gradient: Gradient,
        center: UnitPoint = .center,
        startRadiusFraction: CGFloat = 0,
        endRadiusFraction: CGFloat = 0.5
    ) -> EllipticalGradient {
        .init(
            gradient: gradient,
            center: center,
            startRadiusFraction: startRadiusFraction,
            endRadiusFraction: endRadiusFraction
        )
    }

    /// A radial gradient that draws an ellipse defined by a collection of
    /// colors.
    ///
    /// The gradient maps its coordinate space to the unit space square
    /// in which its center and radii are defined, then stretches that
    /// square to fill its bounding rect, possibly also stretching the
    /// circular gradient to have elliptical contours.
    ///
    /// For example, an elliptical gradient used as a background:
    ///
    ///     .background(.ellipticalGradient(colors: [.red, .yellow]))
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static func ellipticalGradient(
        colors: [Color],
        center: UnitPoint = .center,
        startRadiusFraction: CGFloat = 0,
        endRadiusFraction: CGFloat = 0.5
    ) -> EllipticalGradient {
        .init(
            colors: colors,
            center: center,
            startRadiusFraction: startRadiusFraction,
            endRadiusFraction: endRadiusFraction
        )
    }

    /// A radial gradient that draws an ellipse defined by a collection of
    /// color stops.
    ///
    /// The gradient maps its coordinate space to the unit space square
    /// in which its center and radii are defined, then stretches that
    /// square to fill its bounding rect, possibly also stretching the
    /// circular gradient to have elliptical contours.
    ///
    /// For example, an elliptical gradient used as a background:
    ///
    ///     .background(.ellipticalGradient(stops: [
    ///         .init(color: .red, location: 0.0),
    ///         .init(color: .yellow, location: 0.9),
    ///         .init(color: .yellow, location: 1.0),
    ///     ]))
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static func ellipticalGradient(
        stops: [Gradient.Stop],
        center: UnitPoint = .center,
        startRadiusFraction: CGFloat = 0,
        endRadiusFraction: CGFloat = 0.5
    ) -> EllipticalGradient {
        .init(
            stops: stops,
            center: center,
            startRadiusFraction: startRadiusFraction,
            endRadiusFraction: endRadiusFraction
        )
    }
}

// MARK: - ShapeStyle + AngularGradient

@available(OpenSwiftUI_v1_0, *)
extension ShapeStyle where Self == AngularGradient {
    /// An angular gradient, which applies the color function as the angle
    /// changes between the start and end angles, and anchored to a relative
    /// center point within the filled shape.
    ///
    /// An angular gradient is also known as a "conic" gradient. If
    /// `endAngle - startAngle > 2π`, the gradient only draws the last complete
    /// turn. If `endAngle - startAngle < 2π`, the gradient fills the missing
    /// area with the colors defined by gradient stop locations at `0` and `1`,
    /// transitioning between the two halfway across the missing area.
    ///
    /// For example, an angular gradient used as a background:
    ///
    ///     let gradient = Gradient(colors: [.red, .yellow])
    ///
    ///     ContentView()
    ///         .background(.angularGradient(
    ///             gradient, center: .center,
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
        _ gradient: Gradient,
        center: UnitPoint,
        startAngle: Angle,
        endAngle: Angle
    ) -> AngularGradient {
        .init(
            gradient: gradient,
            center: center,
            startAngle: startAngle,
            endAngle: endAngle
        )
    }

    /// An angular gradient defined by a collection of colors.
    ///
    /// For more information on how to use angular gradients, see
    /// ``ShapeStyle/angularGradient(_:center:startAngle:endAngle:)``.
    ///
    /// - Parameters:
    ///   - colors: The colors of the gradient, evenly spaced along its full
    ///     length.
    ///   - center: The relative center of the gradient, mapped from the unit
    ///     space into the bounding rectangle of the filled shape.
    ///   - startAngle: The angle that marks the beginning of the gradient.
    ///   - endAngle: The angle that marks the end of the gradient.
    @_alwaysEmitIntoClient
    public static func angularGradient(
        colors: [Color],
        center: UnitPoint,
        startAngle: Angle,
        endAngle: Angle
    ) -> AngularGradient {
        .init(
            colors: colors,
            center: center,
            startAngle: startAngle,
            endAngle: endAngle
        )
    }

    /// An angular gradient defined by a collection of color stops.
    ///
    /// For more information on how to use angular gradients, see
    /// ``ShapeStyle/angularGradient(_:center:startAngle:endAngle:)``.
    ///
    /// - Parameters:
    ///   - stops: The color stops of the gradient, defining each component
    ///     color and their relative location along the gradient's full length.
    ///   - center: The relative center of the gradient, mapped from the unit
    ///     space into the bounding rectangle of the filled shape.
    ///   - startAngle: The angle that marks the beginning of the gradient.
    ///   - endAngle: The angle that marks the end of the gradient.
    @_alwaysEmitIntoClient
    public static func angularGradient(
        stops: [Gradient.Stop],
        center: UnitPoint,
        startAngle: Angle,
        endAngle: Angle
    ) -> AngularGradient {
        .init(
            stops: stops,
            center: center,
            startAngle: startAngle,
            endAngle: endAngle
        )
    }
}

// MARK: - ShapeStyle + ConicGradient

@available(OpenSwiftUI_v1_0, *)
extension ShapeStyle where Self == AngularGradient {
    /// A conic gradient that completes a full turn, optionally starting from
    /// a given angle and anchored to a relative center point within the filled
    /// shape.
    ///
    /// For example, a conic gradient used as a background:
    ///
    ///     let gradient = Gradient(colors: [.red, .yellow])
    ///
    ///     ContentView()
    ///         .background(.conicGradient(gradient, center: .center))
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
        _ gradient: Gradient,
        center: UnitPoint,
        angle: Angle = .zero
    ) -> AngularGradient {
        .init(gradient: gradient, center: center, angle: angle)
    }

    /// A conic gradient defined by a collection of colors that completes a full
    /// turn.
    ///
    /// For more information on how to use conic gradients, see
    /// ``ShapeStyle/conicGradient(_:center:angle:)``.
    ///
    /// - Parameters:
    ///   - colors: The colors of the gradient, evenly spaced along its full
    ///     length.
    ///   - center: The relative center of the gradient, mapped from the unit
    ///     space into the bounding rectangle of the filled shape.
    ///   - angle: The angle to offset the beginning of the gradient's full
    ///     turn.
    @_alwaysEmitIntoClient
    public static func conicGradient(
        colors: [Color],
        center: UnitPoint,
        angle: Angle = .zero
    ) -> AngularGradient {
        .init(colors: colors, center: center, angle: angle)
    }

    /// A conic gradient defined by a collection of color stops that completes a
    /// full turn.
    ///
    /// For more information on how to use conic gradients, see
    /// ``ShapeStyle/conicGradient(_:center:angle:)``.
    ///
    /// - Parameters:
    ///   - stops: The color stops of the gradient, defining each component
    ///     color and their relative location along the gradient's full length.
    ///   - center: The relative center of the gradient, mapped from the unit
    ///     space into the bounding rectangle of the filled shape.
    ///   - angle: The angle to offset the beginning of the gradient's full
    ///     turn.
    @_alwaysEmitIntoClient
    public static func conicGradient(
        stops: [Gradient.Stop],
        center: UnitPoint,
        angle: Angle = .zero
    ) -> AngularGradient {
        .init(stops: stops, center: center, angle: angle)
    }
}

// MARK: - LinearGradient

/// A linear gradient.
///
/// The gradient applies the color function along an axis, as defined by its
/// start and end points. The gradient maps the unit space points into the
/// bounding rectangle of each shape filled with the gradient.
///
/// When using a linear gradient as a shape style, you can also use
/// ``ShapeStyle/linearGradient(_:startPoint:endPoint:)``.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct LinearGradient: Paint, View, Sendable {
    package var gradient: Gradient
    package var startPoint: UnitPoint
    package var endPoint: UnitPoint

    /// Creates a linear gradient from a base gradient.
    public init(gradient: Gradient, startPoint: UnitPoint, endPoint: UnitPoint) {
        self.gradient = gradient
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    /// Creates a linear gradient from a collection of colors.
    @_alwaysEmitIntoClient
    public init(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) {
        self.init(
            gradient: Gradient(colors: colors),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    /// Creates a linear gradient from a collection of color stops.
    @_alwaysEmitIntoClient
    public init(stops: [Gradient.Stop], startPoint: UnitPoint, endPoint: UnitPoint) {
        self.init(
            gradient: Gradient(stops: stops),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    package struct _Paint: ResolvedPaint {
        package var gradient: ResolvedGradient
        package var startPoint: UnitPoint
        package var endPoint: UnitPoint

        package init(gradient: ResolvedGradient, startPoint: UnitPoint, endPoint: UnitPoint) {
            self.gradient = gradient
            self.startPoint = startPoint
            self.endPoint = endPoint
        }

        package static var leafProtobufTag: CodableResolvedPaint.Tag? { .linearGradient }
    }

    package func resolvePaint(in environment: EnvironmentValues) -> _Paint {
        _Paint(
            gradient: gradient.resolve(in: environment),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        gradient.fallbackColor
    }

    @available(*, deprecated, message: "obsolete")
    @_alwaysEmitIntoClient
    public static func _makeView<S>(
        view: _GraphValue<_ShapeView<S, Self>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs where S: Shape {
        _ShapeView<S, Self>._makeView(view: view, inputs: inputs)
    }
}

// MARK: - RadialGradient

/// A radial gradient.
///
/// The gradient applies the color function as the distance from a center
/// point, scaled to fit within the defined start and end radii. The
/// gradient maps the unit space center point into the bounding rectangle of
/// each shape filled with the gradient.
///
/// When using a radial gradient as a shape style, you can also use
/// ``ShapeStyle/radialGradient(_:center:startRadius:endRadius:)``.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct RadialGradient: Paint, View, Sendable {
    package var gradient: Gradient
    package var center: UnitPoint
    package var startRadius: CGFloat
    package var endRadius: CGFloat

    /// Creates a radial gradient from a base gradient.
    public init(
        gradient: Gradient,
        center: UnitPoint,
        startRadius: CGFloat,
        endRadius: CGFloat
    ) {
        self.gradient = gradient
        self.center = center
        self.startRadius = startRadius
        self.endRadius = endRadius
    }

    /// Creates a radial gradient from a collection of colors.
    @_alwaysEmitIntoClient
    public init(
        colors: [Color],
        center: UnitPoint,
        startRadius: CGFloat,
        endRadius: CGFloat
    ) {
        self.init(
            gradient: Gradient(colors: colors),
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }

    /// Creates a radial gradient from a collection of color stops.
    @_alwaysEmitIntoClient
    public init(
        stops: [Gradient.Stop],
        center: UnitPoint,
        startRadius: CGFloat,
        endRadius: CGFloat
    ) {
        self.init(
            gradient: Gradient(stops: stops),
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }

    package struct _Paint: ResolvedPaint {
        package var gradient: ResolvedGradient
        package var center: UnitPoint
        package var startRadius: CGFloat
        package var endRadius: CGFloat

        package init(
            gradient: ResolvedGradient,
            center: UnitPoint,
            startRadius: CGFloat,
            endRadius: CGFloat
        ) {
            self.gradient = gradient
            self.center = center
            self.startRadius = startRadius
            self.endRadius = endRadius
        }

        package static var leafProtobufTag: CodableResolvedPaint.Tag? { .radialGradient }
    }

    package func resolvePaint(in environment: EnvironmentValues) -> _Paint {
        _Paint(
            gradient: gradient.resolve(in: environment),
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }

    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        gradient.fallbackColor
    }

    @available(*, deprecated, message: "obsolete")
    @_alwaysEmitIntoClient
    public static func _makeView<S>(
        view: _GraphValue<_ShapeView<S, Self>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs where S: Shape {
        _ShapeView<S, Self>._makeView(view: view, inputs: inputs)
    }
}

// MARK: - EllipticalGradient

/// A radial gradient that draws an ellipse.
///
/// The gradient maps its coordinate space to the unit space square
/// in which its center and radii are defined, then stretches that
/// square to fill its bounding rect, possibly also stretching the
/// circular gradient to have elliptical contours.
///
/// For example, an elliptical gradient centered on the view, filling
/// its bounds:
///
///     EllipticalGradient(gradient: .init(colors: [.red, .yellow]))
///
/// When using an elliptical gradient as a shape style, you can also use
/// ``ShapeStyle/ellipticalGradient(_:center:startRadiusFraction:endRadiusFraction:)``.
@available(OpenSwiftUI_v3_0, *)
@frozen
public struct EllipticalGradient: Paint, View, Sendable {
    package var gradient: Gradient
    package var center: UnitPoint
    package var startRadiusFraction: CGFloat
    package var endRadiusFraction: CGFloat

    /// Creates an elliptical gradient.
    ///
    /// For example, an elliptical gradient centered on the top-leading
    /// corner of the view:
    ///
    ///     EllipticalGradient(
    ///         gradient: .init(colors: [.blue, .green]),
    ///         center: .topLeading,
    ///         startRadiusFraction: 0,
    ///         endRadiusFraction: 1)
    ///
    /// - Parameters:
    ///  - gradient: The colors and their parametric locations.
    ///  - center: The center of the circle, in [0, 1] coordinates.
    ///  - startRadiusFraction: The start radius value, as a fraction
    ///    between zero and one. Zero maps to the center point, one
    ///    maps to the diameter of the unit circle.
    ///  - endRadiusFraction: The end radius value, as a fraction
    ///    between zero and one. Zero maps to the center point, one
    ///    maps to the diameter of the unit circle.
    public init(
        gradient: Gradient,
        center: UnitPoint = .center,
        startRadiusFraction: CGFloat = 0,
        endRadiusFraction: CGFloat = 0.5
    ) {
        self.gradient = gradient
        self.center = center
        self.startRadiusFraction = startRadiusFraction
        self.endRadiusFraction = endRadiusFraction
    }

    /// Creates an elliptical gradient from a collection of colors.
    ///
    /// For example, an elliptical gradient centered on the top-leading
    /// corner of the view:
    ///
    ///     EllipticalGradient(
    ///         colors: [.blue, .green],
    ///         center: .topLeading,
    ///         startRadiusFraction: 0,
    ///         endRadiusFraction: 1)
    ///
    /// - Parameters:
    ///  - colors: The colors, evenly distributed throughout the gradient.
    ///  - center: The center of the circle, in [0, 1] coordinates.
    ///  - startRadiusFraction: The start radius value, as a fraction
    ///    between zero and one. Zero maps to the center point, one
    ///    maps to the diameter of the unit circle.
    ///  - endRadiusFraction: The end radius value, as a fraction
    ///    between zero and one. Zero maps to the center point, one
    ///    maps to the diameter of the unit circle.
    public init(
        colors: [Color],
        center: UnitPoint = .center,
        startRadiusFraction: CGFloat = 0,
        endRadiusFraction: CGFloat = 0.5
    ) {
        self.init(
            gradient: Gradient(colors: colors),
            center: center,
            startRadiusFraction: startRadiusFraction,
            endRadiusFraction: endRadiusFraction
        )
    }

    /// Creates an elliptical gradient from a collection of color stops.
    ///
    /// For example, an elliptical gradient centered on the top-leading
    /// corner of the view, with some extra green area:
    ///
    ///     EllipticalGradient(
    ///         stops: [
    ///             .init(color: .blue, location: 0.0),
    ///             .init(color: .green, location: 0.9),
    ///             .init(color: .green, location: 1.0),
    ///         ],
    ///         center: .topLeading,
    ///         startRadiusFraction: 0,
    ///         endRadiusFraction: 1)
    ///
    /// - Parameters:
    ///  - stops: The colors and their parametric locations.
    ///  - center: The center of the circle, in [0, 1] coordinates.
    ///  - startRadiusFraction: The start radius value, as a fraction
    ///    between zero and one. Zero maps to the center point, one
    ///    maps to the diameter of the unit circle.
    ///  - endRadiusFraction: The end radius value, as a fraction
    ///    between zero and one. Zero maps to the center point, one
    ///    maps to the diameter of the unit circle.
    public init(
        stops: [Gradient.Stop],
        center: UnitPoint = .center,
        startRadiusFraction: CGFloat = 0,
        endRadiusFraction: CGFloat = 0.5
    ) {
        self.init(
            gradient: Gradient(stops: stops),
            center: center,
            startRadiusFraction: startRadiusFraction,
            endRadiusFraction: endRadiusFraction
        )
    }

    package struct _Paint: ResolvedPaint {
        package var gradient: ResolvedGradient
        package var center: UnitPoint
        package var startRadiusFraction: CGFloat
        package var endRadiusFraction: CGFloat

        package init(
            gradient: ResolvedGradient,
            center: UnitPoint,
            startRadiusFraction: CGFloat,
            endRadiusFraction: CGFloat
        ) {
            self.gradient = gradient
            self.center = center
            self.startRadiusFraction = startRadiusFraction
            self.endRadiusFraction = endRadiusFraction
        }

        package static var leafProtobufTag: CodableResolvedPaint.Tag? { .ellipticalGradient }
    }

    package func resolvePaint(in environment: EnvironmentValues) -> _Paint {
        _Paint(
            gradient: gradient.resolve(in: environment),
            center: center,
            startRadiusFraction: startRadiusFraction,
            endRadiusFraction: endRadiusFraction
        )
    }

    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        gradient.fallbackColor
    }
}

// MARK: - AngularGradient

/// An angular gradient.
///
/// An angular gradient is also known as a "conic" gradient. This gradient
/// applies the color function as the angle changes, relative to a center
/// point and defined start and end angles. If `endAngle - startAngle > 2π`,
/// the gradient only draws the last complete turn. If
/// `endAngle - startAngle < 2π`, the gradient fills the missing area with
/// the colors defined by gradient locations one and zero, transitioning
/// between the two halfway across the missing area. The gradient maps the
/// unit space center point into the bounding rectangle of each shape filled
/// with the gradient.
///
/// When using an angular gradient as a shape style, you can also use
/// ``ShapeStyle/angularGradient(_:center:startAngle:endAngle:)``,
/// ``ShapeStyle/conicGradient(_:center:angle:)``, or similar methods.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct AngularGradient: Paint, View, Sendable {
    package var gradient: Gradient
    package var center: UnitPoint
    package var startAngle: Angle
    package var endAngle: Angle

    /// Creates an angular gradient.
    public init(
        gradient: Gradient,
        center: UnitPoint,
        startAngle: Angle = .zero,
        endAngle: Angle = .zero
    ) {
        self.gradient = gradient
        self.center = center
        self.startAngle = startAngle
        self.endAngle = endAngle
    }

    /// Creates an angular gradient from a collection of colors.
    @_alwaysEmitIntoClient
    public init(
        colors: [Color],
        center: UnitPoint,
        startAngle: Angle,
        endAngle: Angle
    ) {
        self.init(
            gradient: Gradient(colors: colors),
            center: center,
            startAngle: startAngle,
            endAngle: endAngle
        )
    }

    /// Creates an angular gradient from a collection of color stops.
    @_alwaysEmitIntoClient
    public init(
        stops: [Gradient.Stop],
        center: UnitPoint,
        startAngle: Angle,
        endAngle: Angle
    ) {
        self.init(
            gradient: Gradient(stops: stops),
            center: center,
            startAngle: startAngle,
            endAngle: endAngle
        )
    }

    /// Creates a conic gradient that completes a full turn.
    public init(gradient: Gradient, center: UnitPoint, angle: Angle = .zero) {
        self.init(
            gradient: gradient,
            center: center,
            startAngle: angle,
            endAngle: angle + .radians(2 * .pi)
        )
    }

    /// Creates a conic gradient from a collection of colors that completes
    /// a full turn.
    @_alwaysEmitIntoClient
    public init(colors: [Color], center: UnitPoint, angle: Angle = .zero) {
        self.init(gradient: Gradient(colors: colors), center: center, angle: angle)
    }

    /// Creates a conic gradient from a collection of color stops that
    /// completes a full turn.
    @_alwaysEmitIntoClient
    public init(stops: [Gradient.Stop], center: UnitPoint, angle: Angle = .zero) {
        self.init(gradient: Gradient(stops: stops), center: center, angle: angle)
    }

    package struct _Paint: ResolvedPaint {
        package var gradient: ResolvedGradient
        package var center: UnitPoint
        package var startAngle: Angle
        package var endAngle: Angle

        package init(
            gradient: ResolvedGradient,
            center: UnitPoint,
            startAngle: Angle,
            endAngle: Angle
        ) {
            self.gradient = gradient
            self.center = center
            self.startAngle = startAngle
            self.endAngle = endAngle
        }

        package static var leafProtobufTag: CodableResolvedPaint.Tag? { .angularGradient }
    }

    package func resolvePaint(in environment: EnvironmentValues) -> _Paint {
        _Paint(
            gradient: gradient.resolve(in: environment),
            center: center,
            startAngle: startAngle,
            endAngle: endAngle
        )
    }

    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        gradient.fallbackColor
    }

    @available(*, deprecated, message: "obsolete")
    @_alwaysEmitIntoClient
    public static func _makeView<S>(
        view: _GraphValue<_ShapeView<S, Self>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs where S: Shape {
        _ShapeView<S, Self>._makeView(view: view, inputs: inputs)
    }
}

// MARK: - LinearGradient._Paint

@available(OpenSwiftUI_v1_0, *)
extension LinearGradient._Paint {
    package func draw(
        path: Path,
        style: PathDrawingStyle,
        in context: GraphicsContext,
        bounds: CGRect?
    ) {
        let rect = bounds ?? path.boundingRect
        context.draw(
            path,
            with: .gradient(
                gradient,
                .axial(startPoint.in(rect), endPoint.in(rect))
            ),
            style: style
        )
    }

    package var isClear: Bool { gradient.isClear }
    package var isOpaque: Bool { gradient.isOpaque }
    package var resolvedGradient: ResolvedGradient? { gradient }

    package typealias AnimatableData = AnimatablePair<
        AnimatablePair<UnitPoint.AnimatableData, UnitPoint.AnimatableData>,
        ResolvedGradient.AnimatableData
    >

    package var animatableData: AnimatableData {
        get {
            AnimatablePair(
                AnimatablePair(startPoint.animatableData, endPoint.animatableData),
                gradient.animatableData
            )
        }
        set {
            startPoint.animatableData = newValue.first.first
            endPoint.animatableData = newValue.first.second
            gradient.animatableData = newValue.second
        }
    }
}

// MARK: - LinearGradient._Paint + ProtobufMessage

@available(OpenSwiftUI_v1_0, *)
extension LinearGradient._Paint: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, gradient)
        try encoder.messageField(2, startPoint)
        try encoder.messageField(3, endPoint)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var gradient = ResolvedGradient()
        var startPoint = UnitPoint()
        var endPoint = UnitPoint()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: gradient = try decoder.messageField(field)
            case 2: startPoint = try decoder.messageField(field)
            case 3: endPoint = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
        self.init(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
    }
}

// MARK: - RadialGradient._Paint

@available(OpenSwiftUI_v1_0, *)
extension RadialGradient._Paint {
    package func draw(
        path: Path,
        style: PathDrawingStyle,
        in context: GraphicsContext,
        bounds: CGRect?
    ) {
        let rect = bounds ?? path.boundingRect
        context.draw(
            path,
            with: .gradient(
                gradient,
                .radial(center.in(rect), startRadius, endRadius)
            ),
            style: style
        )
    }

    package var isClear: Bool { gradient.isClear }
    package var isOpaque: Bool { gradient.isOpaque }
    package var resolvedGradient: ResolvedGradient? { gradient }

    package typealias AnimatableData = AnimatablePair<
        AnimatablePair<UnitPoint.AnimatableData, ResolvedGradient.AnimatableData>,
        AnimatablePair<CGFloat, CGFloat>
    >

    package var animatableData: AnimatableData {
        get {
            AnimatablePair(
                AnimatablePair(center.animatableData, gradient.animatableData),
                AnimatablePair(startRadius, endRadius)
            )
        }
        set {
            center.animatableData = newValue.first.first
            gradient.animatableData = newValue.first.second
            startRadius = newValue.second.first
            endRadius = newValue.second.second
        }
    }
}

// MARK: - RadialGradient._Paint + ProtobufMessage

@available(OpenSwiftUI_v1_0, *)
extension RadialGradient._Paint: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, gradient)
        try encoder.messageField(2, center)
        encoder.cgFloatField(3, startRadius)
        encoder.cgFloatField(4, endRadius)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var gradient = ResolvedGradient()
        var center = UnitPoint()
        var startRadius: CGFloat = 0
        var endRadius: CGFloat = 0
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: gradient = try decoder.messageField(field)
            case 2: center = try decoder.messageField(field)
            case 3: startRadius = try decoder.cgFloatField(field)
            case 4: endRadius = try decoder.cgFloatField(field)
            default: try decoder.skipField(field)
            }
        }
        self.init(
            gradient: gradient,
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }
}

// MARK: - EllipticalGradient._Paint

@available(OpenSwiftUI_v3_0, *)
extension EllipticalGradient._Paint {
    package func draw(
        path: Path,
        style: PathDrawingStyle,
        in context: GraphicsContext,
        bounds: CGRect?
    ) {
        let bounds = bounds ?? path.boundingRect
        let ellipse = CGRect(origin: center.in(bounds), size: bounds.size)
        context.draw(
            path,
            with: .gradient(
                gradient,
                .elliptical(ellipse, startRadiusFraction, endRadiusFraction)
            ),
            style: style
        )
    }

    package var isClear: Bool { gradient.isClear }
    package var isOpaque: Bool { gradient.isOpaque }
    package var resolvedGradient: ResolvedGradient? { gradient }

    package typealias AnimatableData = AnimatablePair<
        AnimatablePair<UnitPoint.AnimatableData, ResolvedGradient.AnimatableData>,
        AnimatablePair<CGFloat, CGFloat>
    >

    package var animatableData: AnimatableData {
        get {
            AnimatablePair(
                AnimatablePair(center.animatableData, gradient.animatableData),
                AnimatablePair(startRadiusFraction, endRadiusFraction)
            )
        }
        set {
            center.animatableData = newValue.first.first
            gradient.animatableData = newValue.first.second
            startRadiusFraction = newValue.second.first
            endRadiusFraction = newValue.second.second
        }
    }
}

// MARK: - EllipticalGradient._Paint + ProtobufMessage

@available(OpenSwiftUI_v3_0, *)
extension EllipticalGradient._Paint: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, gradient)
        try encoder.messageField(2, center)
        encoder.cgFloatField(3, startRadiusFraction)
        encoder.cgFloatField(4, endRadiusFraction)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var gradient = ResolvedGradient()
        var center = UnitPoint.center
        var startRadiusFraction: CGFloat = 0
        var endRadiusFraction: CGFloat = 0
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: gradient = try decoder.messageField(field)
            case 2: center = try decoder.messageField(field)
            case 3: startRadiusFraction = try decoder.cgFloatField(field)
            case 4: endRadiusFraction = try decoder.cgFloatField(field)
            default: try decoder.skipField(field)
            }
        }
        self.init(
            gradient: gradient,
            center: center,
            startRadiusFraction: startRadiusFraction,
            endRadiusFraction: endRadiusFraction
        )
    }
}

// MARK: - AngularGradient._Paint

@available(OpenSwiftUI_v1_0, *)
extension AngularGradient._Paint {
    package func draw(
        path: Path,
        style: PathDrawingStyle,
        in context: GraphicsContext,
        bounds: CGRect?
    ) {
        let rect = bounds ?? path.boundingRect
        context.draw(
            path,
            with: .gradient(
                gradient,
                .angular(center.in(rect), startAngle, endAngle)
            ),
            style: style
        )
    }

    package var isClear: Bool { gradient.isClear }
    package var isOpaque: Bool { gradient.isOpaque }
    package var resolvedGradient: ResolvedGradient? { gradient }

    package typealias AnimatableData = AnimatablePair<
        AnimatablePair<UnitPoint.AnimatableData, ResolvedGradient.AnimatableData>,
        AnimatablePair<Angle.AnimatableData, Angle.AnimatableData>
    >

    package var animatableData: AnimatableData {
        get {
            AnimatablePair(
                AnimatablePair(center.animatableData, gradient.animatableData),
                AnimatablePair(startAngle.animatableData, endAngle.animatableData)
            )
        }
        set {
            center.animatableData = newValue.first.first
            gradient.animatableData = newValue.first.second
            startAngle.animatableData = newValue.second.first
            endAngle.animatableData = newValue.second.second
        }
    }
}

// MARK: - AngularGradient._Paint + ProtobufMessage

@available(OpenSwiftUI_v1_0, *)
extension AngularGradient._Paint: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, gradient)
        try encoder.messageField(2, center)
        encoder.cgFloatField(3, startAngle.radians)
        encoder.cgFloatField(4, endAngle.radians)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var gradient = ResolvedGradient()
        var center = UnitPoint()
        var startAngle = Angle.zero
        var endAngle = Angle.zero
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: gradient = try decoder.messageField(field)
            case 2: center = try decoder.messageField(field)
            case 3: startAngle = .radians(try decoder.cgFloatField(field))
            case 4: endAngle = .radians(try decoder.cgFloatField(field))
            default: try decoder.skipField(field)
            }
        }
        self.init(
            gradient: gradient,
            center: center,
            startAngle: startAngle,
            endAngle: endAngle
        )
    }
}

// TODO: ConicGradient
