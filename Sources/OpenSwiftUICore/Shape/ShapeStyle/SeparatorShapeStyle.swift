//
//  SeparatorShapeStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 43B3709EE4A9B8504AC89AFCD0D99421

extension ShapeStyle where Self == SeparatorShapeStyle {
    /// A style appropriate for foreground separator or border lines.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static var separator: SeparatorShapeStyle { .init() }
}

/// A style appropriate for foreground separator or border lines.
///
/// You can also use ``ShapeStyle/separator`` to construct this style.
public struct SeparatorShapeStyle: ShapeStyle {
    /// Creates a new separator shape style instance.
    public init() {}

    nonisolated public static func _makeView<S>(
        view: _GraphValue<_ShapeView<S, SeparatorShapeStyle>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs where S: Shape {
        legacyMakeShapeView(view: view, inputs: inputs)
    }

    public typealias Resolved = Never
}

extension SeparatorShapeStyle {
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        let environment = shape.environment
        if let backgroundMaterial = environment.backgroundMaterial {
            ForegroundMaterialStyle(material: backgroundMaterial)._apply(to: &shape)
        } else {
            let colorScheme = environment.colorScheme
            let colorSchemeContrast = environment.colorSchemeContrast
            let color = Color(
                .sRGB,
                red: colorScheme != .light ? 80 / 255 : 60 / 255,
                green: colorScheme != .light ? 80 / 255 : 60 / 255,
                blue: colorScheme != .light ? 88 / 255 : 67 / 255,
                opacity: ((colorScheme != .light) ? 0.6 : 0.29) + ((colorSchemeContrast != .standard) ? 0.08 : 0.0)
            )
            color._apply(to: &shape)
        }
    }

    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        type.result = .bool(true)
    }
}

private struct DefaultSeparatorShapeStyleKey: EnvironmentKey {
    static var defaultValue: HierarchicalShapeStyle { .quaternary }
}

extension EnvironmentValues {
    package var defaultSeparatorShapeStyle: HierarchicalShapeStyle {
        get { self[DefaultSeparatorShapeStyleKey.self] }
        set { self[DefaultSeparatorShapeStyleKey.self] = newValue }
    }
}
