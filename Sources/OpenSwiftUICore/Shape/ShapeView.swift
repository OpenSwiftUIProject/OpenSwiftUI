//
//  ShapeView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by _ShapeView.makeView

public import Foundation

// MARK: - Shape + Extension (disfavoredOverload)

extension Shape {
    /// Fills this shape with a color or gradient.
    ///
    /// - Parameters:
    ///   - content: The color or gradient to use when filling this shape.
    ///   - style: The style options that determine how the fill renders.
    /// - Returns: A shape filled with the color or gradient you supply.
    @inlinable
    @_disfavoredOverload
    nonisolated public func fill<S>(_ content: S, style: FillStyle = FillStyle()) -> some View where S: ShapeStyle {
        _ShapeView(shape: self, style: content, fillStyle: style)
    }

    /// Fills this shape with the foreground color.
    ///
    /// - Parameter style: The style options that determine how the fill
    ///   renders.
    /// - Returns: A shape filled with the foreground color.
    @inlinable
    @_disfavoredOverload
    nonisolated public func fill(style: FillStyle = FillStyle()) -> some View {
        _ShapeView(shape: self, style: .foreground, fillStyle: style)
    }

    /// Traces the outline of this shape with a color or gradient.
    ///
    /// The following example adds a dashed purple stroke to a `Capsule`:
    ///
    ///     Capsule()
    ///     .stroke(
    ///         Color.purple,
    ///         style: StrokeStyle(
    ///             lineWidth: 5,
    ///             lineCap: .round,
    ///             lineJoin: .miter,
    ///             miterLimit: 0,
    ///             dash: [5, 10],
    ///             dashPhase: 0
    ///         )
    ///     )
    ///
    /// - Parameters:
    ///   - content: The color or gradient with which to stroke this shape.
    ///   - style: The stroke characteristics --- such as the line's width and
    ///     whether the stroke is dashed --- that determine how to render this
    ///     shape.
    /// - Returns: A stroked shape.
    @inlinable
    @_disfavoredOverload
    nonisolated public func stroke<S>(_ content: S, style: StrokeStyle) -> some View where S: ShapeStyle {
        _ShapeView(
            shape: stroke(style: style),
            style: content
        )
    }

    /// Traces the outline of this shape with a color or gradient.
    ///
    /// The following example draws a circle with a purple stroke:
    ///
    ///     Circle().stroke(Color.purple, lineWidth: 5)
    ///
    /// - Parameters:
    ///   - content: The color or gradient with which to stroke this shape.
    ///   - lineWidth: The width of the stroke that outlines this shape.
    /// - Returns: A stroked shape.
    @inlinable
    @_disfavoredOverload
    nonisolated public func stroke<S>(_ content: S, lineWidth: CGFloat = 1) -> some View where S: ShapeStyle {
        _ShapeView(
            shape: stroke(style: StrokeStyle(lineWidth: lineWidth)),
            style: content
        )
    }
}

// MARK: - Shape + View

extension Shape {
    public var body: _ShapeView<Self, ForegroundStyle> {
        _ShapeView(shape: self, style: ForegroundStyle())
    }
}

extension Shape {
    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        makeView(view: view, inputs: inputs)
    }

    nonisolated public static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        makeViewList(view: view, inputs: inputs)
    }
}

// MARK: - ShapeStyle + View

extension ShapeStyle where Self: View, Body == _ShapeView<Rectangle, Self> {
    public var body: _ShapeView<Rectangle, Self> {
        _ShapeView(shape: Rectangle(), style: self)
    }
}

// MARK: - _ShapeView

/// A view that renders a shape in a provided shape style.
///
/// You don't use this view directly. Instead you create a Shape and use the
/// ``Shape/fill(_:style:)`` modifier to provide a shape and fill style
///
///     Rectangle()
///         .fill(.red)
///
@frozen
public struct _ShapeView<Content, Style>: View, UnaryView, ShapeStyledLeafView, PrimitiveView/*, LeafViewLayout*/ where Content: Shape, Style: ShapeStyle {
    public var shape: Content

    public var style: Style

    public var fillStyle: FillStyle

    @inlinable
    public init(shape: Content, style: Style, fillStyle: FillStyle = FillStyle()) {
        self.shape = shape
        self.style = style
        self.fillStyle = fillStyle
    }

    nonisolated public static func _makeView(view: _GraphValue<_ShapeView<Content, Style>>, inputs: _ViewInputs) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }

    package func shape(in size: CGSize) -> FramedShape {
        let path = shape.effectivePath(in: CGRect(origin: .zero, size: size))
        // FIXME
        return FramedShape(shape: .path(path, fillStyle), frame: CGRect(origin: .zero, size: size))
    }

    package func sizeThatFits(in proposedSize: _ProposedSize) -> CGSize {
        shape.sizeThatFits(.init(proposedSize))
    }
}

@available(*, unavailable)
extension _ShapeView: Sendable {}

extension ShapeStyle {
    package static func legacyMakeShapeView<S>(view: _GraphValue<_ShapeView<S, Self>>, inputs: _ViewInputs) -> _ViewOutputs where S: Shape {
        _ShapeView._makeView(view: view, inputs: inputs)
    }
}

// MARK: - ShapeView

/// A view that provides a shape that you can use for drawing operations.
///
/// Use this type with the drawing methods on ``Shape`` to apply multiple fills
/// and/or strokes to a shape. For example, the following code applies a fill
/// and stroke to a capsule shape:
///
///     Capsule()
///         .fill(.yellow)
///         .stroke(.blue, lineWidth: 8)
///
public protocol ShapeView<Content>: View {
    associatedtype Content: Shape
    var shape: Self.Content { get }
}

// MARK: - Shape + Extension

extension Shape {
    /// Fills this shape with a color or gradient.
    ///
    /// - Parameters:
    ///   - content: The color or gradient to use when filling this shape.
    ///   - style: The style options that determine how the fill renders.
    /// - Returns: A shape filled with the color or gradient you supply.
    @_alwaysEmitIntoClient
    nonisolated public func fill<S>(_ content: S = .foreground, style: FillStyle = FillStyle()) -> _ShapeView<Self, S> where S: ShapeStyle {
        _ShapeView(shape: self, style: content, fillStyle: style)
    }

    /// Traces the outline of this shape with a color or gradient.
    ///
    /// The following example adds a dashed purple stroke to a `Capsule`:
    ///
    ///     Capsule()
    ///     .stroke(
    ///         Color.purple,
    ///         style: StrokeStyle(
    ///             lineWidth: 5,
    ///             lineCap: .round,
    ///             lineJoin: .miter,
    ///             miterLimit: 0,
    ///             dash: [5, 10],
    ///             dashPhase: 0
    ///         )
    ///     )
    ///
    /// - Parameters:
    ///   - content: The color or gradient with which to stroke this shape.
    ///   - style: The stroke characteristics --- such as the line's width and
    ///     whether the stroke is dashed --- that determine how to render this
    ///     shape.
    /// - Returns: A stroked shape.
    @_alwaysEmitIntoClient
    nonisolated public func stroke<S>(_ content: S, style: StrokeStyle, antialiased: Bool = true) -> StrokeShapeView<Self, S, EmptyView> where S: ShapeStyle {
        StrokeShapeView(
            shape: self,
            style: content,
            strokeStyle: style,
            isAntialiased: antialiased,
            background: EmptyView()
        )
    }

    /// Traces the outline of this shape with a color or gradient.
    ///
    /// The following example draws a circle with a purple stroke:
    ///
    ///     Circle().stroke(Color.purple, lineWidth: 5)
    ///
    /// - Parameters:
    ///   - content: The color or gradient with which to stroke this shape.
    ///   - lineWidth: The width of the stroke that outlines this shape.
    /// - Returns: A stroked shape.
    @_alwaysEmitIntoClient
    nonisolated public func stroke<S>(_ content: S, lineWidth: CGFloat = 1, antialiased: Bool = true) -> StrokeShapeView<Self, S, EmptyView> where S: ShapeStyle {
        stroke(
            content,
            style: StrokeStyle(lineWidth: lineWidth),
            antialiased: antialiased
        )
    }
}

// MARK: - InsettableShape + Extension

extension InsettableShape {
    /// Returns a view that is the result of insetting `self` by
    /// `style.lineWidth / 2`, stroking the resulting shape with
    /// `style`, and then filling with `content`.
    @_alwaysEmitIntoClient
    nonisolated public func strokeBorder<S>(_ content: S = .foreground, style: StrokeStyle, antialiased: Bool = true) -> StrokeBorderShapeView<Self, S, EmptyView> where S: ShapeStyle {
        StrokeBorderShapeView(
            shape: self,
            style: content,
            strokeStyle: style,
            isAntialiased: antialiased,
            background: EmptyView()
        )
    }

    /// Returns a view that is the result of filling the `lineWidth`-sized
    /// border (aka inner stroke) of `self` with `content`. This is
    /// equivalent to insetting `self` by `lineWidth / 2` and stroking the
    /// resulting shape with `lineWidth` as the line-width.
    @_alwaysEmitIntoClient
    nonisolated public func strokeBorder<S>(_ content: S = .foreground, lineWidth: CGFloat = 1, antialiased: Bool = true) -> StrokeBorderShapeView<Self, S, EmptyView> where S: ShapeStyle {
        strokeBorder(
            content,
            style: StrokeStyle(lineWidth: lineWidth),
            antialiased: antialiased
        )
    }
}

extension _ShapeView: ShapeView {}

// MARK: - FillShapeView

/// A shape provider that fills its shape.
///
/// You do not create this type directly, it is the return type of `Shape.fill`.
@frozen
public struct FillShapeView<Content, Style, Background>: ShapeView, PrimitiveView, UnaryView where Content: Shape, Style: ShapeStyle, Background: View {
    @usableFromInline
    typealias ViewType = ModifiedContent<_ShapeView<Content, Style>, _BackgroundModifier<Background>>

    @usableFromInline
    var view: ViewType

    /// The shape that this type draws and provides for other drawing
    /// operations.
    @_alwaysEmitIntoClient
    public var shape: Content {
        get { view.content.shape }
        set { view.content.shape = newValue }
    }

    /// The style that fills this view's shape.
    @_alwaysEmitIntoClient
    public var style: Style {
        get { view.content.style }
        set { view.content.style = newValue }
    }

    /// The fill style used when filling this view's shape.
    @_alwaysEmitIntoClient
    public var fillStyle: FillStyle {
        get { view.content.fillStyle }
        set { view.content.fillStyle = newValue }
    }

    /// The background shown beneath this view.
    @_alwaysEmitIntoClient
    public var background: Background {
        get { view.modifier.background }
        set { view.modifier.background = newValue }
    }

    /// Create a FillShapeView.
    @_alwaysEmitIntoClient
    public init(shape: Content, style: Style, fillStyle: FillStyle, background: Background) {
        view = .init(
            content: _ShapeView(
                shape: shape,
                style: style,
                fillStyle: fillStyle
            ),
            modifier: .init(background: background)
        )
    }

    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        ViewType._makeView(view: view[offset: { .of(&$0.view) }], inputs: inputs)
    }
}

@available(*, unavailable)
extension FillShapeView: Sendable {}

// MARK: - StrokeShapeView

/// A shape provider that strokes its shape.
///
/// You don't create this type directly; it's the return type of
/// `Shape.stroke`.
@frozen
public struct StrokeShapeView<Content, Style, Background> : ShapeView, PrimitiveView, UnaryView where Content: Shape, Style: ShapeStyle, Background: View {
    @usableFromInline
    typealias ViewType = ModifiedContent<_ShapeView<_StrokedShape<Content>, Style>, _BackgroundModifier<Background>>

    @usableFromInline
    var view: ViewType

    /// The shape that this type draws and provides for other drawing
    /// operations.
    @_alwaysEmitIntoClient
    public var shape: Content {
        get { view.content.shape.shape }
        set { view.content.shape.shape = newValue }
    }

    /// The style that strokes this view's shape.
    @_alwaysEmitIntoClient
    public var style: Style {
        get { view.content.style }
        set { view.content.style = newValue }
    }

    /// The stroke style used when stroking this view's shape.
    @_alwaysEmitIntoClient
    public var strokeStyle: StrokeStyle {
        get { view.content.shape.style }
        set { view.content.shape.style = newValue }
    }

    /// Whether this shape should be drawn antialiased.
    @_alwaysEmitIntoClient
    public var isAntialiased: Swift.Bool {
        get { view.content.fillStyle.isAntialiased }
        set { view.content.fillStyle.isAntialiased = newValue }
    }

    /// The background shown beneath this view.
    @_alwaysEmitIntoClient
    public var background: Background {
        get { view.modifier.background }
        set { view.modifier.background = newValue }
    }

    /// Create a StrokeShapeView.
    @_alwaysEmitIntoClient
    public init(shape: Content, style: Style, strokeStyle: StrokeStyle, isAntialiased: Swift.Bool, background: Background) {
        view = .init(
            content: _ShapeView(
                shape: _StrokedShape(shape: shape, style: strokeStyle),
                style: style,
                fillStyle: .init(antialiased: isAntialiased)
            ),
            modifier: .init(background: background)
        )
    }
    
    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        ViewType._makeView(view: view[offset: { .of(&$0.view) }], inputs: inputs)
    }
}

@available(*, unavailable)
extension StrokeShapeView: Sendable {}

// MARK: - StrokeBorderShapeView

/// A shape provider that strokes the border of its shape.
///
/// You don't create this type directly; it's the return type of
/// `Shape.strokeBorder`.
@frozen
public struct StrokeBorderShapeView<Content, Style, Background>: ShapeView, PrimitiveView, UnaryView where Content: InsettableShape, Style: ShapeStyle, Background: View {
    @usableFromInline
    typealias ViewType = ModifiedContent<_ShapeView<_StrokedShape<Content.InsetShape>, Style>, _BackgroundModifier<Background>>

    /// The shape that this type draws and provides for other drawing
    /// operations.
    public var shape: Content

    @usableFromInline
    var view: ViewType

    /// The style that strokes the border of this view's shape.
    @_alwaysEmitIntoClient
    public var style: Style {
        get { view.content.style }
        set { view.content.style = newValue }
    }

    /// The stroke style used when stroking this view's shape.
    @_alwaysEmitIntoClient
    public var strokeStyle: StrokeStyle {
        get { view.content.shape.style }
        set { view.content.shape.style = newValue }
    }

    /// Whether this shape should be drawn antialiased.
    @_alwaysEmitIntoClient
    public var isAntialiased: Swift.Bool {
        get { view.content.fillStyle.isAntialiased }
        set { view.content.fillStyle.isAntialiased = newValue }
    }

    /// The background shown beneath this view.
    @_alwaysEmitIntoClient
    public var background: Background {
        get { view.modifier.background }
        set { view.modifier.background = newValue }
    }

    /// Create a stroke border shape.
    @_alwaysEmitIntoClient
    public init(shape: Content, style: Style, strokeStyle: StrokeStyle, isAntialiased: Swift.Bool, background: Background) {
        self.shape = shape
        view = .init(
            content: _ShapeView(
                shape: _StrokedShape(
                    shape: shape.inset(by: strokeStyle.lineWidth * 0.5),
                    style: strokeStyle
                ),
                style: style,
                fillStyle: .init(antialiased: isAntialiased)
            ),
            modifier: .init(background: background)
        )
    }

    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        ViewType._makeView(view: view[offset: { .of(&$0.view) }], inputs: inputs)
    }
}

@available(*, unavailable)
extension StrokeBorderShapeView: Sendable {}

// MARK: - ShapeView + Extension

extension ShapeView {
    /// Fills this shape with a color or gradient.
    ///
    /// - Parameters:
    ///   - content: The color or gradient to use when filling this shape.
    ///   - style: The style options that determine how the fill renders.
    /// - Returns: A shape filled with the color or gradient you supply.
    @_alwaysEmitIntoClient
    nonisolated public func fill<S>(_ content: S = .foreground, style: FillStyle = FillStyle()) -> FillShapeView<Self.Content, S, Self> where S: ShapeStyle {
        FillShapeView(
            shape: shape,
            style: content,
            fillStyle: style,
            background: self
        )
    }

    /// Traces the outline of this shape with a color or gradient.
    ///
    /// The following example adds a dashed purple stroke to a `Capsule`:
    ///
    ///     Capsule()
    ///     .stroke(
    ///         Color.purple,
    ///         style: StrokeStyle(
    ///             lineWidth: 5,
    ///             lineCap: .round,
    ///             lineJoin: .miter,
    ///             miterLimit: 0,
    ///             dash: [5, 10],
    ///             dashPhase: 0
    ///         )
    ///     )
    ///
    /// - Parameters:
    ///   - content: The color or gradient with which to stroke this shape.
    ///   - style: The stroke characteristics --- such as the line's width and
    ///     whether the stroke is dashed --- that determine how to render this
    ///     shape.
    /// - Returns: A stroked shape.
    @_alwaysEmitIntoClient
    nonisolated public func stroke<S>(_ content: S, style: StrokeStyle, antialiased: Swift.Bool = true) -> StrokeShapeView<Self.Content, S, Self> where S: ShapeStyle {
        StrokeShapeView(
            shape: shape,
            style: content,
            strokeStyle: style,
            isAntialiased: antialiased,
            background: self
        )
    }

    /// Traces the outline of this shape with a color or gradient.
    ///
    /// The following example draws a circle with a purple stroke:
    ///
    ///     Circle().stroke(Color.purple, lineWidth: 5)
    ///
    /// - Parameters:
    ///   - content: The color or gradient with which to stroke this shape.
    ///   - lineWidth: The width of the stroke that outlines this shape.
    /// - Returns: A stroked shape.
    @_alwaysEmitIntoClient
    nonisolated public func stroke<S>(_ content: S, lineWidth: CGFloat = 1, antialiased: Swift.Bool = true) -> StrokeShapeView<Self.Content, S, Self> where S: ShapeStyle {
        stroke(
            content,
            style: StrokeStyle(lineWidth: lineWidth),
            antialiased: antialiased
        )
    }
}

extension ShapeView where Content: InsettableShape {
    /// Returns a view that's the result of insetting this view by half of its style's line width.
    ///
    /// This method strokes the resulting shape with
    /// `style` and fills it with `content`.
    @_alwaysEmitIntoClient
    nonisolated public func strokeBorder<S>(_ content: S = .foreground, style: StrokeStyle, antialiased: Bool = true) -> StrokeBorderShapeView<Self.Content, S, Self> where S: ShapeStyle {
        StrokeBorderShapeView(
            shape: shape,
            style: content,
            strokeStyle: style,
            isAntialiased: antialiased,
            background: self
        )
    }

    /// Returns a view that's the result of filling an inner stroke of this view with the content you supply.
    ///
    /// This is equivalent to insetting `self` by `lineWidth / 2` and stroking the
    /// resulting shape with `lineWidth` as the line-width.
    @_alwaysEmitIntoClient
    nonisolated public func strokeBorder<S>(_ content: S = .foreground, lineWidth: CGFloat = 1, antialiased: Bool = true) -> StrokeBorderShapeView<Self.Content, S, Self> where S: ShapeStyle {
        strokeBorder(
            content,
            style: StrokeStyle(lineWidth: lineWidth),
            antialiased: antialiased
        )
    }
}
