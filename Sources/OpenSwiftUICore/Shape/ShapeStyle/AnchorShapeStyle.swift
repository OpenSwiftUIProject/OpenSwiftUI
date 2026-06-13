//
//  AnchorShapeStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

// MARK: - _AnchoredShapeStyle

/// Paint adaptor to override the unit space to absolute space
/// coordinate conversion.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _AnchoredShapeStyle<S>: ShapeStyle where S: ShapeStyle {
    public var style: S

    public var bounds: CGRect

    @inlinable
    init(style: S, bounds: CGRect) {
        self.style = style
        self.bounds = bounds
    }

    nonisolated public static func _makeView<T>(
        view: _GraphValue<_ShapeView<T, _AnchoredShapeStyle<S>>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs where T: Shape {
        legacyMakeShapeView(view: view, inputs: inputs)
    }

    @available(OpenSwiftUI_v5_0, *)
    public typealias Resolved = Never
}

@available(OpenSwiftUI_v3_0, *)
extension _AnchoredShapeStyle {
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        shape.bounds = bounds
        style._apply(to: &shape)
    }

    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        S._apply(to: &type)
    }
}

// MARK: - AnchoredResolvedPaint

package struct AnchoredResolvedPaint<P>: ResolvedPaint where P: ResolvedPaint {
    package var paint: P

    package var bounds: CGRect

    package init(_ paint: P, bounds: CGRect) {
        self.paint = paint
        self.bounds = bounds
    }

    package func draw(
        path: Path,
        style: PathDrawingStyle,
        in ctx: GraphicsContext,
        bounds outerBounds: CGRect?
    ) {
        paint.draw(path: path, style: style, in: ctx, bounds: bounds)
    }

    package var isClear: Bool {
        paint.isClear
    }

    package var isOpaque: Bool {
        paint.isOpaque
    }

    package var isCALayerCompatible: Bool {
        paint.isCALayerCompatible
    }

    package typealias AnimatableData = AnimatablePair<P.AnimatableData, CGRect.AnimatableData>

    package var animatableData: AnimatableData {
        get {
            AnimatableData(paint.animatableData, bounds.animatableData)
        }
        set {
            paint.animatableData = newValue.first
            bounds.animatableData = newValue.second
        }
    }

    package static var leafProtobufTag: CodableResolvedPaint.Tag? {
        nil
    }

    package static func == (a: AnchoredResolvedPaint<P>, b: AnchoredResolvedPaint<P>) -> Bool {
        a.paint == b.paint && a.bounds == b.bounds
    }
}

extension AnchoredResolvedPaint: ProtobufEncodableMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try paint.encodePaint(to: &encoder)
        try encoder.messageField(7, EdgeInsets(
            top: bounds.origin.x,
            leading: bounds.origin.y,
            bottom: bounds.size.width,
            trailing: bounds.size.height
        ))
    }
}

// MARK: - ShapeStyle + Anchor

@available(OpenSwiftUI_v1_0, *)
extension ShapeStyle {
    /// Maps a shape style's unit-space coordinates to the absolute coordinates
    /// of a given rectangle.
    ///
    /// Some shape styles have colors or patterns that vary
    /// with position based on ``UnitPoint`` coordinates. For example, you
    /// can create a ``LinearGradient`` using ``UnitPoint/top`` and
    /// ``UnitPoint/bottom`` as the start and end points:
    ///
    ///     let gradient = LinearGradient(
    ///         colors: [.red, .yellow],
    ///         startPoint: .top,
    ///         endPoint: .bottom)
    ///
    /// When rendering such styles, OpenSwiftUI maps the unit space coordinates to
    /// the absolute coordinates of the filled shape. However, you can tell
    /// OpenSwiftUI to use a different set of coordinates by supplying a rectangle
    /// to the `in(_:)` method. Consider two resizable rectangles using the
    /// gradient defined above:
    ///
    ///     HStack {
    ///         Rectangle()
    ///             .fill(gradient)
    ///         Rectangle()
    ///             .fill(gradient.in(CGRect(x: 0, y: 0, width: 0, height: 300)))
    ///     }
    ///     .onTapGesture { isBig.toggle() }
    ///     .frame(height: isBig ? 300 : 50)
    ///     .animation(.easeInOut)
    ///
    /// When `isBig` is true — defined elsewhere as a private ``State``
    /// variable — the rectangles look the same, because their heights
    /// match that of the modified gradient:
    ///
    /// ![Two identical, tall rectangles, with a gradient that starts red at
    /// the top and transitions to yellow at the bottom.](ShapeStyle-in-1)
    ///
    /// When the user toggles `isBig` by tapping the ``HStack``, the
    /// rectangles shrink, but the gradients each react in a different way:
    ///
    /// ![Two short rectangles with different coloration. The first has a
    /// gradient that transitions top to bottom from full red to full yellow.
    /// The second starts as red at the top and then begins to transition
    /// to yellow toward the bottom.](ShapeStyle-in-2)
    ///
    /// OpenSwiftUI remaps the gradient of the first rectangle to the new frame
    /// height, so that you continue to see the full range of colors in a
    /// smaller area. For the second rectangle, the modified gradient retains
    /// a mapping to the full height, so you instead see only a small part of
    /// the overall gradient. Animation helps to visualize the difference.
    ///
    /// - Parameter rect: A rectangle that gives the absolute coordinates over
    ///   which to map the shape style.
    /// - Returns: A new shape style mapped to the coordinates given by `rect`.
    @inlinable
    public func `in`(_ rect: CGRect) -> some ShapeStyle {
        _AnchoredShapeStyle(style: self, bounds: rect)
    }
}
