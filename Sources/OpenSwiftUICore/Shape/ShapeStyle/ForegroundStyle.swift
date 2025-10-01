//
//  ForegroundStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: BEFE9363F68E039B4AB6422B8AA4535A (SwiftUICore)

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
        currentForegroundStyle ?? .init(.foreground)
    }
}

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

/// The foreground style in the current context.
///
/// You can also use ``ShapeStyle/foreground`` to construct this style.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct ForegroundStyle: ShapeStyle, PrimitiveShapeStyle {
    /// Creates a foreground style instance.
    @inlinable
    public init() {}
    
    nonisolated public static func _makeView<S>(view: _GraphValue<_ShapeView<S, ForegroundStyle>>, inputs: _ViewInputs) -> _ViewOutputs where S: Shape {
        legacyMakeShapeView(view: view, inputs: inputs)
    }
}

extension ForegroundStyle {
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        if shape.activeRecursiveStyles.contains(.foreground) {
            LegacyContentStyle.sharedPrimary._apply(to: &shape)
        } else {
            shape.effectiveForegroundStyle._apply(to: &shape)
            shape.activeRecursiveStyles.subtract(.foreground)
        }
    }
    
    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        type.result = .bool(true)
    }
}
