//
//  ForegroundStyleModifier.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

// MARK: - View + foregroundStyle

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Sets a view's foreground elements to use a given style.
    ///
    /// Use this method to style
    /// foreground content like text, shapes, and template images
    /// (including symbols):
    ///
    ///     HStack {
    ///         Image(systemName: "triangle.fill")
    ///         Text("Hello, world!")
    ///         RoundedRectangle(cornerRadius: 5)
    ///             .frame(width: 40, height: 20)
    ///     }
    ///     .foregroundStyle(.teal)
    ///
    /// The example above creates a row of ``ShapeStyle/teal`` foreground
    /// elements:
    ///
    /// ![A screenshot of a teal triangle, string, and rounded
    /// rectangle.](View-foregroundStyle-1)
    ///
    /// You can use any style that conforms to the ``ShapeStyle`` protocol,
    /// like the ``ShapeStyle/teal`` color in the example above, or the
    /// ``ShapeStyle/linearGradient(colors:startPoint:endPoint:)`` gradient
    /// shown below:
    ///
    ///     Text("Gradient Text")
    ///         .font(.largeTitle)
    ///         .foregroundStyle(
    ///             .linearGradient(
    ///                 colors: [.yellow, .blue],
    ///                 startPoint: .top,
    ///                 endPoint: .bottom
    ///             )
    ///         )
    ///
    /// ![A screenshot of the words Gradient Text, with letters that
    ///   appear yellow at the top, and transition to blue
    ///   toward the bottom.](View-foregroundStyle-2)
    ///
    /// > Tip: If you want to fill a single ``Shape`` instance with a style,
    /// use the ``Shape/fill(style:)`` shape modifier instead because it's more
    /// efficient.
    ///
    /// OpenSwiftUI creates a context-dependent render for a given style.
    /// For example, a ``Color`` that you load from an asset catalog
    /// can have different light and dark appearances, while some styles
    /// also vary by platform.
    ///
    /// Hierarchical foreground styles like ``ShapeStyle/secondary``
    /// don't impose a style of their own, but instead modify other styles.
    /// In particular, they modify the primary
    /// level of the current foreground style to the degree given by
    /// the hierarchical style's name.
    /// To find the current foreground style to modify, OpenSwiftUI looks for
    /// the innermost containing style that you apply with the
    /// `foregroundStyle(_:)` or the ``View/foregroundColor(_:)`` modifier.
    /// If you haven't specified a style, OpenSwiftUI uses the default foreground
    /// style, as in the following example:
    ///
    ///     VStack(alignment: .leading) {
    ///         Label("Primary", systemImage: "1.square.fill")
    ///         Label("Secondary", systemImage: "2.square.fill")
    ///             .foregroundStyle(.secondary)
    ///     }
    ///
    /// ![A screenshot of two labels with the text primary and secondary.
    /// The first appears in a brighter shade than the
    /// second, both in a grayscale color.](View-foregroundStyle-3)
    ///
    /// If you add a foreground style on the enclosing
    /// ``VStack``, the hierarchical styling responds accordingly:
    ///
    ///     VStack(alignment: .leading) {
    ///         Label("Primary", systemImage: "1.square.fill")
    ///         Label("Secondary", systemImage: "2.square.fill")
    ///             .foregroundStyle(.secondary)
    ///     }
    ///     .foregroundStyle(.blue)
    ///
    /// ![A screenshot of two labels with the text primary and secondary.
    /// The first appears in a brighter shade than the
    /// second, both tinted blue.](View-foregroundStyle-4)
    ///
    /// When you apply a custom style to a view, the view disables the vibrancy
    /// effect for foreground elements in that view, or in any of its child
    /// views, that it would otherwise gain from adding a background material
    /// --- for example, using the ``View/background(_:ignoresSafeAreaEdges:)``
    /// modifier. However, hierarchical styles applied to the default foreground
    /// don't disable vibrancy.
    ///
    /// - Parameter style: The color or pattern to use when filling in the
    ///   foreground elements. To indicate a specific value, use ``Color`` or
    ///   ``ShapeStyle/image(_:sourceRect:scale:)``, or one of the gradient
    ///   types, like
    ///   ``ShapeStyle/linearGradient(colors:startPoint:endPoint:)``. To set a
    ///   style that’s relative to the containing view's style, use one of the
    ///   semantic styles, like ``ShapeStyle/primary``.
    ///
    /// - Returns: A view that uses the given foreground style.
    @inlinable
    nonisolated public func foregroundStyle<S>(_ style: S) -> some View where S: ShapeStyle {
        modifier(_ForegroundStyleModifier(style: style))
    }

    /// Sets the primary and secondary levels of the foreground
    /// style in the child view.
    ///
    /// OpenSwiftUI uses these styles when rendering child views
    /// that don't have an explicit rendering style, like images,
    /// text, shapes, and so on.
    ///
    /// Symbol images within the view hierarchy use the
    /// ``SymbolRenderingMode/palette`` rendering mode when you apply this
    /// modifier, if you don't explicitly specify another mode.
    ///
    /// - Parameters:
    ///   - primary: The primary color or pattern to use when filling in
    ///     the foreground elements. To indicate a specific value, use ``Color``
    ///     or ``ShapeStyle/image(_:sourceRect:scale:)``, or one of the gradient
    ///     types, like
    ///     ``ShapeStyle/linearGradient(colors:startPoint:endPoint:)``. To set a
    ///     style that’s relative to the containing view's style, use one of the
    ///     semantic styles, like ``ShapeStyle/primary``.
    ///   - secondary: The secondary color or pattern to use when
    ///     filling in the foreground elements.
    ///
    /// - Returns: A view that uses the given foreground styles.
    @inlinable
    nonisolated public func foregroundStyle<S1, S2>(_ primary: S1, _ secondary: S2) -> some View where S1: ShapeStyle, S2: ShapeStyle {
        modifier(_ForegroundStyleModifier2(primary: primary, secondary: secondary))
    }
    
    /// Sets the primary, secondary, and tertiary levels of
    /// the foreground style.
    ///
    /// OpenSwiftUI uses these styles when rendering child views
    /// that don't have an explicit rendering style, like images,
    /// text, shapes, and so on.
    ///
    /// Symbol images within the view hierarchy use the
    /// ``SymbolRenderingMode/palette`` rendering mode when you apply this
    /// modifier, if you don't explicitly specify another mode.
    ///
    /// - Parameters:
    ///   - primary: The primary color or pattern to use when filling in
    ///     the foreground elements. To indicate a specific value, use ``Color``
    ///     or ``ShapeStyle/image(_:sourceRect:scale:)``, or one of the gradient
    ///     types, like
    ///     ``ShapeStyle/linearGradient(colors:startPoint:endPoint:)``. To set a
    ///     style that’s relative to the containing view's style, use one of the
    ///     semantic styles, like ``ShapeStyle/primary``.
    ///   - secondary: The secondary color or pattern to use when
    ///     filling in the foreground elements.
    ///   - tertiary: The tertiary color or pattern to use when
    ///     filling in the foreground elements.
    ///
    /// - Returns: A view that uses the given foreground styles.
    @inlinable
    nonisolated public func foregroundStyle<S1, S2, S3>(_ primary: S1, _ secondary: S2, _ tertiary: S3) -> some View where S1: ShapeStyle, S2: ShapeStyle, S3: ShapeStyle {
        modifier(_ForegroundStyleModifier3(primary: primary, secondary: secondary, tertiary: tertiary))
    }
}

// MARK: - _ForegroundStyleModifier

@available(OpenSwiftUI_v3_0, *)
@frozen
@MainActor
@preconcurrency
public struct _ForegroundStyleModifier<Style>: PrimitiveViewModifier, ViewInputsModifier where Style: ShapeStyle {
    nonisolated package static var graphInputsSemantics: Semantics? { .v4 }
    
    public var style: Style
    
    @inlinable
    nonisolated public init(style: Style) {
        self.style = style
    }
    
    public nonisolated static func _makeViewInputs(modifier: _GraphValue<_ForegroundStyleModifier<Style>>, inputs: inout _ViewInputs) {
        openSwiftUIUnimplementedFailure()
    }
    
    public typealias Body = Never
}

@available(*, unavailable)
extension _ForegroundStyleModifier: Sendable {}

// MARK: - _ForegroundStyleModifier2

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _ForegroundStyleModifier2<S1, S2>: PrimitiveViewModifier, ViewInputsModifier where S1: ShapeStyle, S2: ShapeStyle {
    nonisolated package static var graphInputsSemantics: Semantics? { .v4 }
    
    public var primary: S1
    public var secondary: S2
    
    @inlinable
    nonisolated public init(primary: S1, secondary: S2) {
        self.primary = primary
        self.secondary = secondary
    }

    nonisolated public static func _makeViewInputs(modifier: _GraphValue<_ForegroundStyleModifier2<S1, S2>>, inputs: inout _ViewInputs) {
        openSwiftUIUnimplementedFailure()
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension _ForegroundStyleModifier2: Sendable {}

// MARK: - _ForegroundStyleModifier3

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _ForegroundStyleModifier3<S1, S2, S3>: PrimitiveViewModifier, ViewInputsModifier where S1: ShapeStyle, S2: ShapeStyle, S3: ShapeStyle {
    nonisolated package static var graphInputsSemantics: Semantics? { .v4 }

    public var primary: S1
    public var secondary: S2
    public var tertiary: S3
    @inlinable
    nonisolated public init(primary: S1, secondary: S2, tertiary: S3) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
    }

    nonisolated public static func _makeViewInputs(modifier: _GraphValue<_ForegroundStyleModifier3<S1, S2, S3>>, inputs: inout _ViewInputs) {
        openSwiftUIUnimplementedFailure()
    }

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    public typealias Body = Never
}

@available(*, unavailable)
extension _ForegroundStyleModifier3: Sendable {}
