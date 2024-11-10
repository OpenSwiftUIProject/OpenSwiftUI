//
//  AnyShapeStyle.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Blocked by _ShapeStyle_Shape

import Foundation

#if OPENSWIFTUI_RELEASE_2024
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
public protocol ShapeStyle {
    /// Returns the view's outputs, for the shape view and its inputs.
    @available(*, deprecated, message: "obsolete")
    static func _makeView<S>(view: _GraphValue<_ShapeView<S, Self>>, inputs: _ViewInputs) -> _ViewOutputs where S : Shape
    
    /// Called to apply the style to the given shape value.
    func _apply(to shape: inout _ShapeStyle_Shape)
    
    /// Called to apply the style to the given shape type.
    static func _apply(to type: inout _ShapeStyle_ShapeType)
    
    /// The type of shape style this will resolve to.
    ///
    /// When you create a custom shape style, Swift infers this type
    /// from your implementation of the required `resolve` function.
    @_weakLinked
    associatedtype Resolved: ShapeStyle = Never
    
    /// Evaluate to a resolved shape style given the current `environment`.
    func resolve(in environment: EnvironmentValues) -> Self.Resolved
}

extension Never: ShapeStyle {
    public static func _makeView(view: _GraphValue<Never>, inputs: _ViewInputs) -> _ViewOutputs {
        fatalError()
    }
}
#elseif OPENSWIFTUI_RELEASE_2021
/// A color or pattern to use when rendering a shape.
///
/// You don't use the `ShapeStyle` protocol directly. Instead, use one of
/// the concrete styles that OpenSwiftUI defines. To indicate a specific color
/// or pattern, you can use ``Color`` or the style returned by
/// ``ShapeStyle/image(_:sourceRect:scale:)``, or one of the gradient
/// types, like the one returned by
/// ``ShapeStyle/radialGradient(_:center:startRadius:endRadius:)``.
/// To set a color that's appropriate for a given context on a given
/// platform, use one of the semantic styles, like ``ShapeStyle/background`` or
/// ``ShapeStyle/primary``.
///
/// You can use a shape style by:
/// * Filling a shape with a style with the ``Shape/fill(_:style:)`` modifier:
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
public protocol ShapeStyle {
    /// Returns the view's outputs, for the shape view and its inputs.
    @available(*, deprecated, message: "obsolete")
    static func _makeView<S>(view: _GraphValue<_ShapeView<S, Self>>, inputs: _ViewInputs) -> _ViewOutputs where S : Shape
    
    /// Called to apply the style to the given shape value.
    func _apply(to shape: inout _ShapeStyle_Shape)
    
    /// Called to apply the style to the given shape type.
    static func _apply(to type: inout _ShapeStyle_ShapeType)
}
#endif


extension ShapeStyle {
    public static func _makeView<S>(view: _GraphValue<_ShapeView<S, Self>>, inputs: _ViewInputs) -> _ViewOutputs where S: Shape {
        legacyMakeShapeView(view: view, inputs: inputs)
    }
    
    static func legacyMakeShapeView<S>(view: _GraphValue<_ShapeView<S, Self>>, inputs: _ViewInputs) -> _ViewOutputs where S: Shape {
        _ShapeView._makeView(view: view, inputs: inputs)
    }
    
    public func _apply(to shape: inout _ShapeStyle_Shape) {}
    public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

#if OPENSWIFTUI_RELEASE_2024

extension ShapeStyle where Resolved == Never {
    public func resolve(in: EnvironmentValues) -> Self.Resolved {
        fatalError()
    }
    
    public static func _apply(to type: inout _ShapeStyle_ShapeType) {}
}

#endif

#if OPENSWIFTUI_RELEASE_2024

// MARK: - _ShapeStyle_Name

package enum _ShapeStyle_Name: UInt8, Equatable, Comparable {
    case foreground
    case background
    case multicolor
    
    package static func < (lhs: _ShapeStyle_Name, rhs: _ShapeStyle_Name) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

#endif

// MARK: - _ShapeStyle_Shape [TODO]

public struct _ShapeStyle_Shape {
    enum Operation {
        case prepare(Text, level: Int)
        case resolveStyle(levels: Range<Int>)
        case fallbackColor(level: Int)
        case multiLevel
        case copyForeground
        case primaryStyle
        case modifyBackground
    }
    
    enum Result {
        case prepared(Text)
        case resolved(ResolvedStyle)
        case style(AnyShapeStyle)
        case color(Color)
        case bool(Bool)
        case none
    }
    
    indirect enum ResolvedStyle {
//        case color(Color.Resolved)
//        case paint(AnyResolvedPaint)
//        case foregroundMaterial(Color.Resolved, ContentStyle.MaterialResolved)
//        case backgroundMaterial(Material.Resolved)
        case array([ResolvedStyle])
//        case blend(GraphicsBlendMode, _ShapeStyle_Graphics.ResolvedBlend)
        case opacity(Float, ResolvedStyle)
//        case multicolor(ResolvedMulticolorStyle)
    }
    
    var operation: Operation
    var result: Result
    var environment: EnvironmentValues
    var bounds: CGRect?
    var role: ShapeRole
    var inRecursiveStyle: Bool
}

// MARK: - _ShapeStyle_ShapeType

public struct _ShapeStyle_ShapeType {
    package var operation: Operation
    package var result: Result
    
    package enum Result {
        case bool(Bool)
        case none
    }
    
    package enum Operation: Hashable {
        case modifiesBackground
    }
}
