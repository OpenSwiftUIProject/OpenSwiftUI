//
//  ShapeStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by Graident

// MARK: - ShapeStyle

/// A color or pattern to use when rendering a shape.
///
/// You create custom shape styles by declaring a type that conforms to the
/// `ShapeStyle` protocol and implementing the required `resolve` function to
/// return a shape style that represents the desired appearance based on the
/// current environment.
///
/// For example this shape style reads the current color scheme from the
/// environment to choose the blend mode its color will be composited with:
///
///     struct MyShapeStyle: ShapeStyle {
///         func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
///             if environment.colorScheme == .light {
///                 return Color.red.blendMode(.lighten)
///             } else {
///                 return Color.red.blendMode(.darken)
///             }
///         }
///     }
///
/// In addition to creating a custom shape style, you can also use one of the
/// concrete styles that OpenSwiftUI defines. To indicate a specific color or
/// pattern, you can use ``Color`` or the style returned by
/// ``ShapeStyle/image(_:sourceRect:scale:)``, or one of the gradient
/// types, like the one returned by
/// ``ShapeStyle/radialGradient(_:center:startRadius:endRadius:)-49kel``.
/// To set a color that's appropriate for a given context on a given
/// platform, use one of the semantic styles, like ``ShapeStyle/background`` or
/// ``ShapeStyle/primary``.
///
/// You can use a shape style by:
/// * Filling a shape with a style with the ``Shape/fill(_:style:)-5fwbj``
///   modifier:
///
///     ```
///     Path { path in
///         path.move(to: .zero)
///         path.addLine(to: CGPoint(x: 50, y: 0))
///         path.addArc(
///             center: .zero,
///             radius: 50,
///             startAngle: .zero,
///             endAngle: .degrees(90),
///             clockwise: false)
///     }
///     .fill(.radial(
///         Gradient(colors: [.yellow, .red]),
///         center: .topLeading,
///         startRadius: 15,
///         endRadius: 80))
///     ```
///
///     ![A screenshot of a quarter of a circle filled with
///     a radial gradient.](ShapeStyle-1)
///
/// * Tracing the outline of a shape with a style with either the
///   ``Shape/stroke(_:lineWidth:)`` or the ``Shape/stroke(_:style:)`` modifier:
///
///     ```
///     RoundedRectangle(cornerRadius: 10)
///         .stroke(.mint, lineWidth: 10)
///         .frame(width: 200, height: 50)
///     ```
///
///     ![A screenshot of a rounded rectangle, outlined in mint.](ShapeStyle-2)
///
/// * Styling the foreground elements in a view with the
///   ``View/foregroundStyle(_:)`` modifier:
///
///     ```
///     VStack(alignment: .leading) {
///         Text("Primary")
///             .font(.title)
///         Text("Secondary")
///             .font(.caption)
///             .foregroundStyle(.secondary)
///     }
///     ```
///
///     ![A screenshot of a title in the primary content color above a
///     subtitle in the secondary content color.](ShapeStyle-3)
@available(OpenSwiftUI_v1_0, *)
public protocol ShapeStyle: Sendable {
    /// Returns the view's outputs, for the shape view and its inputs.
    @available(*, deprecated, message: "obsolete")
    static func _makeView<S>(view: _GraphValue<_ShapeView<S, Self>>, inputs: _ViewInputs) -> _ViewOutputs where S: Shape
    
    /// Called to apply the style to the given shape value.
    @available(OpenSwiftUI_v3_0, *)
    func _apply(to shape: inout _ShapeStyle_Shape)
    
    /// Called to apply the style to the given shape type.
    @available(OpenSwiftUI_v3_0, *)
    static func _apply(to type: inout _ShapeStyle_ShapeType)
    
    /// The type of shape style this will resolve to.
    ///
    /// When you create a custom shape style, Swift infers this type
    /// from your implementation of the required `resolve` function.
    @available(OpenSwiftUI_v5_0, *)
    @_weakLinked
    associatedtype Resolved: ShapeStyle = Never
    
    /// Evaluate to a resolved shape style given the current `environment`.
    @available(OpenSwiftUI_v5_0, *)
    func resolve(in environment: EnvironmentValues) -> Self.Resolved
}

// MARK: - PrimitiveShapeStyle

package protocol PrimitiveShapeStyle: ShapeStyle where Resolved == Never {}

// MARK: - ShapeStyle + Never

@available(OpenSwiftUI_v5_0, *)
extension Never: ShapeStyle {
    public typealias Resolved = Never
    
    public static func _makeView<S>(view: _GraphValue<_ShapeView<S, Never>>, inputs: _ViewInputs) -> _ViewOutputs where S: Shape{
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@available(OpenSwiftUI_v5_0, *)
extension ShapeStyle where Resolved == Never {
    public func resolve(in: EnvironmentValues) -> Self.Resolved {
        _openSwiftUIBaseClassAbstractMethod()
    }
    
    public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

// MARK: - ShapeStyle + Default implementation

@available(OpenSwiftUI_v3_0, *)
extension ShapeStyle {
    package typealias Name = _ShapeStyle_Name
    package typealias Pack = _ShapeStyle_Pack
    package typealias ResolverMode = _ShapeStyle_ResolverMode
    
    nonisolated public static func _makeView<S>(view: _GraphValue<_ShapeView<S, Self>>, inputs: _ViewInputs) -> _ViewOutputs where S: Shape {
        legacyMakeShapeView(view: view, inputs: inputs)
    }
    
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        guard Resolved.self != Never.self else {
            return
        }
        resolve(in: shape.environment)._apply(to: &shape)
    }
    
    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        guard Resolved.self != Never.self else {
            return
        }
        Resolved._apply(to: &type)
    }
    
    @_spi(Private)
    public func fallbackColor(in environment: EnvironmentValues, level: Int = 0) -> Color? {
        var shape = _ShapeStyle_Shape(operation: .fallbackColor(level: level), environment: environment)
        _apply(to: &shape)
        switch shape.result {
        case let .color(color): return color
        default: return nil
        }
    }

    package func resolveBackgroundMaterial(in environment: EnvironmentValues, level: Int = 0) -> Material.ResolvedMaterial? {
        let name = ShapeStyle.Name.background
        var shape = _ShapeStyle_Shape(
            operation: .resolveStyle(name: name, levels: level ..< level + 1),
            environment: environment
        )
        _apply(to: &shape)
        let style = shape.stylePack[name, level]
        switch style.fill {
        case let .backgroundMaterial(resolvedMaterial):
            return resolvedMaterial
        default:
            return nil
        }
    }

    // package func resolveGradient(in environment: EnvironmentValues, level: Int = 0) -> ResolvedGradient?

    package func copyStyle(name: Name = .foreground, in env: EnvironmentValues, foregroundStyle: AnyShapeStyle? = nil) -> AnyShapeStyle {
        var shape = _ShapeStyle_Shape(operation: .copyStyle(name: name), environment: env, foregroundStyle: foregroundStyle)
        _apply(to: &shape)
        switch shape.result {
            case let .style(style): return style
            default: return AnyShapeStyle(self)
        }
    }
    
    package func mapCopiedStyle<S>(in shape: inout _ShapeStyle_Shape, body: (AnyShapeStyle) -> S) where S: ShapeStyle {
        guard case .copyStyle = shape.operation else {
            return
        }
        _apply(to: &shape)
        guard case let .style(style) = shape.result else {
            return
        }
        shape.result = .style(AnyShapeStyle(body(style)))
    }
    
    package func primaryStyle(in env: EnvironmentValues) -> AnyShapeStyle? {
        var shape = _ShapeStyle_Shape(operation: .primaryStyle, environment: env)
        _apply(to: &shape)
        switch shape.result {
            case let .style(style): return style
            default: return nil
        }
    }
    
    package func isMultiLevel(in env: EnvironmentValues) -> Bool {
        var shape = _ShapeStyle_Shape(operation: .multiLevel, environment: env)
        _apply(to: &shape)
        switch shape.result {
            case let .bool(value): return value
            default: return false
        }
    }
}
