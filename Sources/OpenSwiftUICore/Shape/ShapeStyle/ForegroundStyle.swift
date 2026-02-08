//
//  ForegroundStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: BEFE9363F68E039B4AB6422B8AA4535A (SwiftUICore)

package import OpenAttributeGraphShims

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

// MARK: - ForegroundStyleKey

private struct ForegroundStyleKey: EnvironmentKey {
    static let defaultValue: AnyShapeStyle? = nil
}

// MARK: - DefaultForegroundStyleKey

private struct DefaultForegroundStyleKey: EnvironmentKey {
    static let defaultValue: AnyShapeStyle? = nil
}

// MARK: - EnvironmentValues + ForegroundStyle

extension EnvironmentValues {
    package var foregroundStyle: AnyShapeStyle? {
        get { self[ForegroundStyleKey.self] }
        set { self[ForegroundStyleKey.self] = newValue }
    }

    package var defaultForegroundStyle: AnyShapeStyle? {
        get { self[DefaultForegroundStyleKey.self] }
        set { self[DefaultForegroundStyleKey.self] = newValue }
    }

    package var currentForegroundStyle: AnyShapeStyle? {
        foregroundStyle ?? defaultForegroundStyle
    }

    package var _effectiveForegroundStyle: AnyShapeStyle {
        currentForegroundStyle ?? HierarchicalShapeStyle.sharedPrimary
    }
}

extension CachedEnvironment.ID {
    package static let foregroundStyle: CachedEnvironment.ID = .init()
}

extension _ViewInputs {
    package var foregroundStyle: Attribute<AnyShapeStyle?> {
        mapEnvironment(id: .foregroundStyle) { $0.foregroundStyle }
    }
}

// MARK: - _DefaultForegroundStyleModifier

struct _DefaultForegroundStyleModifier<Style>: PrimitiveViewModifier, ViewInputsModifier where Style: ShapeStyle {
    var style: Style?

    nonisolated static func _makeViewInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs.environment = Attribute(
            DefaultForegroundStyleEnvironment(
                modifier: modifier.value,
                environment: inputs.environment
            )
        )
    }

    private struct DefaultForegroundStyleEnvironment: Rule {
        @Attribute var modifier: _DefaultForegroundStyleModifier
        @Attribute var environment: EnvironmentValues

        var value: EnvironmentValues {
            var environment = environment
            environment.defaultForegroundStyle = modifier.style.map {
                $0.copyStyle(in: environment)
            }
            return environment
        }
    }
}

// MARK: - _ForegroundStyleModifier

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _ForegroundStyleModifier<Style>: PrimitiveViewModifier, ViewInputsModifier where Style: ShapeStyle {
    package static var graphInputsSemantics: Semantics? { .v4 }

    public var style: Style
    
    @inlinable
    public init(style: Style) {
        self.style = style
    }
    
    nonisolated public static func _makeViewInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs.environment = Attribute(
            ForegroundStyleEnvironment(
                modifier: modifier.value,
                environment: inputs.environment
            )
        )
    }

    private struct ForegroundStyleEnvironment: Rule {
        @Attribute var modifier: _ForegroundStyleModifier
        @Attribute var environment: EnvironmentValues

        var value: EnvironmentValues {
            var environment = environment
            environment.foregroundStyle = modifier.style.copyStyle(in: environment)
            return environment
        }
    }
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

    nonisolated public static func _makeViewInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs.environment = Attribute(
            ForegroundStyleEnvironment(
                modifier: modifier.value,
                environment: inputs.environment
            )
        )
    }

    private struct ForegroundStyleEnvironment: Rule {
        @Attribute var modifier: _ForegroundStyleModifier2
        @Attribute var environment: EnvironmentValues

        var value: EnvironmentValues {
            var environment = environment
            let primary = modifier.primary.copyStyle(in: environment)
            let secondary = modifier.secondary.copyStyle(in: environment)
            environment.foregroundStyle = AnyShapeStyle(ShapeStylePair(primary, secondary))
            return environment
        }
    }
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

    nonisolated public static func _makeViewInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs.environment = Attribute(
            ForegroundStyleEnvironment(
                modifier: modifier.value,
                environment: inputs.environment
            )
        )
    }

    private struct ForegroundStyleEnvironment: Rule {
        @Attribute var modifier: _ForegroundStyleModifier3
        @Attribute var environment: EnvironmentValues

        var value: EnvironmentValues {
            var environment = environment
            let primary = modifier.primary.copyStyle(in: environment)
            let secondary = modifier.secondary.copyStyle(in: environment)
            let tertiary = modifier.tertiary.copyStyle(in: environment)
            environment.foregroundStyle = AnyShapeStyle(ShapeStyleTriple(primary, secondary, tertiary))
            return environment
        }
    }
}

@available(*, unavailable)
extension _ForegroundStyleModifier3: Sendable {}

// MARK: - ShapeStyle + ForegroundStyle

@available(OpenSwiftUI_v1_0, *)
extension ShapeStyle where Self == ForegroundStyle {

    /// The foreground style in the current context.
    ///
    /// Access this value to get the style OpenSwiftUI uses for foreground elements,
    /// like text, symbols, and shapes, in the current context. Use the
    /// ``View/foregroundStyle(_:)`` modifier to set a new foreground style for
    /// a given view and its child views.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static var foreground: ForegroundStyle {
        .init()
    }
}

// MARK: - ForegroundStyle

/// The foreground style in the current context.
///
/// You can also use ``ShapeStyle/foreground`` to construct this style.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct ForegroundStyle: ShapeStyle, PrimitiveShapeStyle {
    static let shared = AnyShapeStyle(ForegroundStyle())

    /// Creates a foreground style instance.
    @inlinable
    public init() {}

    nonisolated public static func _makeView<S>(
        view: _GraphValue<_ShapeView<S, Self>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs where S: Shape {
        legacyMakeShapeView(view: view, inputs: inputs)
    }
}

extension ForegroundStyle {
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        if shape.activeRecursiveStyles.contains(.foreground) {
            LegacyContentStyle.sharedPrimary._apply(to: &shape)
        } else {
            shape.activeRecursiveStyles.formUnion(.foreground)
            shape.effectiveForegroundStyle._apply(to: &shape)
            shape.activeRecursiveStyles.subtract(.foreground)
        }
    }

    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        type.result = .bool(true)
    }
}
