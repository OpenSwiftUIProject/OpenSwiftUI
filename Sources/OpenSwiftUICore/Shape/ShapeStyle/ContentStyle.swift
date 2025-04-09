//
//  ContentStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: BE30CA4BBA5F98638AD9D34F1557FB4D (SwiftUICore)

// MARK: - ShapeStyle + HierarchicalShapeStyle

extension ShapeStyle where Self == HierarchicalShapeStyle {
    /// A shape style that maps to the first level of the current content style.
    ///
    /// This hierarchical style maps to the first level of the current
    /// foreground style, or to the first level of the default foreground style
    /// if you haven't set a foreground style in the view's environment. You
    /// typically set a foreground style by supplying a non-hierarchical style
    /// to the ``View/foregroundStyle(_:)`` modifier.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static var primary: HierarchicalShapeStyle { .primary }

    /// A shape style that maps to the second level of the current content style.
    ///
    /// This hierarchical style maps to the second level of the current
    /// foreground style, or to the second level of the default foreground style
    /// if you haven't set a foreground style in the view's environment. You
    /// typically set a foreground style by supplying a non-hierarchical style
    /// to the ``View/foregroundStyle(_:)`` modifier.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static var secondary: HierarchicalShapeStyle { .secondary }

    /// A shape style that maps to the third level of the current content
    /// style.
    ///
    /// This hierarchical style maps to the third level of the current
    /// foreground style, or to the third level of the default foreground style
    /// if you haven't set a foreground style in the view's environment. You
    /// typically set a foreground style by supplying a non-hierarchical style
    /// to the ``View/foregroundStyle(_:)`` modifier.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static var tertiary: HierarchicalShapeStyle { .tertiary }

    /// A shape style that maps to the fourth level of the current content
    /// style.
    ///
    /// This hierarchical style maps to the fourth level of the current
    /// foreground style, or to the fourth level of the default foreground style
    /// if you haven't set a foreground style in the view's environment. You
    /// typically set a foreground style by supplying a non-hierarchical style
    /// to the ``View/foregroundStyle(_:)`` modifier.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static var quaternary: HierarchicalShapeStyle { .quaternary }
}

extension ShapeStyle where Self == HierarchicalShapeStyle {
    /// A shape style that maps to the fifth level of the current content
    /// style.
    ///
    /// This hierarchical style maps to the fifth level of the current
    /// foreground style, or to the fifth level of the default foreground style
    /// if you haven't set a foreground style in the view's environment. You
    /// typically set a foreground style by supplying a non-hierarchical style
    /// to the ``View/foregroundStyle(_:)`` modifier.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static var quinary: HierarchicalShapeStyle { .quinary }
}

// MARK: - ContentStyle

package enum ContentStyle {
    package enum ID: Int8 {
        case primary
        case secondary
        case tertiary
        case quaternary
        case quinary
    }

    package enum Primitive {
        case fill
        case stroke
        case separator
        
        package init(_ role: ShapeRole) {
            switch role {
            case .fill: self = .fill
            case .stroke: self = .stroke
            case .separator: self = .separator
            }
        }
    }

    package struct Style: Hashable {
        package var id: ID

        package var primitive: Primitive

        package init(id: ID, primitive: Primitive) {
            self.id = id
            self.primitive = primitive
        }
    }

    package struct MaterialStyle: Hashable {
        package var material: Material.ResolvedMaterial

        package var base: Style

        package init(material: Material.ResolvedMaterial, base: Style) {
            self.material = material
            self.base = base
        }
    }
}

// MARK: - HierarchicalShapeStyle

/// A shape style that maps to one of the numbered content styles.
@frozen
public struct HierarchicalShapeStyle: ShapeStyle, PrimitiveShapeStyle {
    package var id: UInt32

    package init(id: UInt32) {
        self.id = id
    }

    /// A shape style that maps to the first level of the current
    /// content style.
    public static let primary: HierarchicalShapeStyle = .init(id: 0)

    /// A shape style that maps to the second level of the current
    /// content style.
    public static let secondary: HierarchicalShapeStyle = .init(id: 1)

    /// A shape style that maps to the third level of the current
    /// content style.
    public static let tertiary: HierarchicalShapeStyle = .init(id: 2)

    /// A shape style that maps to the fourth level of the current
    /// content style.
    public static let quaternary: HierarchicalShapeStyle = .init(id: 3)
    
    package static let sharedPrimary = AnyShapeStyle(HierarchicalShapeStyle.primary)

    package var level: Int {
        Int(id)
    }

    public func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
        case .primaryStyle:
            shape.result = .style(HierarchicalShapeStyle.sharedPrimary)
        default:
            if shape.activeRecursiveStyles.contains(.content) {
                LegacyContentStyle.sharedPrimary._apply(to: &shape)
            } else {
                shape.activeRecursiveStyles.formUnion(.content)
                if let foregroundStyle = shape.foregroundStyle ?? shape.currentForegroundStyle {
                    let primaryStyle = foregroundStyle.primaryStyle(in: shape.environment) ?? foregroundStyle
                    apply(primaryStyle, to: &shape)
                } else {
                    switch shape.role {
                    case .separator:
                        SeparatorShapeStyle()._apply(to: &shape)
                    default:
                        if let backgroundMaterial = shape.environment.backgroundMaterial {
                            let foregroundMaterialStyle = ForegroundMaterialStyle(material: backgroundMaterial)
                            apply(foregroundMaterialStyle, to: &shape)
                        } else {
                            apply(SystemColorsStyle(), to: &shape)
                        }
                    }
                }
                shape.activeRecursiveStyles.subtract(.content)
            }
        }
    }

    private func apply<S>(_ style: S, to shape: inout _ShapeStyle_Shape) where S: ShapeStyle {
        if level == 0 {
            if case let .copyStyle(name) = shape.operation {
                shape.result = .style(AnyShapeStyle(style))
            } else {
                style._apply(to: &shape)
            }
        } else {
            let offsetStyle = style.offset(by: level)
            if case let .copyStyle(name) = shape.operation {
                shape.result = .style(AnyShapeStyle(offsetStyle))
            } else {
                offsetStyle._apply(to: &shape)
            }
        }
    }

    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        type.result = .bool(true)
    }
}

extension HierarchicalShapeStyle {
    /// A shape style that maps to the fifth level of the current
    /// content style.
    public static let quinary: HierarchicalShapeStyle = .init(id: 4)
}

// MARK: - LegacyContentStyle

package struct LegacyContentStyle: ShapeStyle, PrimitiveShapeStyle {
    package static let sharedPrimary = AnyShapeStyle(LegacyContentStyle(id: .primary, color: .primary))

    package var id: ContentStyle.ID

    package var color: Color

    package func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
        case .primaryStyle:
            shape.result = .style(LegacyContentStyle.sharedPrimary)
        default:
            if let backgroundMaterial = shape.environment.backgroundMaterial {
                let style = ForegroundMaterialStyle(material: backgroundMaterial)
                if id == .primary {
                    style._apply(to: &shape)
                } else {
                    style.offset(by: Int(id.rawValue))._apply(to: &shape)
                }
            } else {
                let style = SystemColorsStyle()
                if id == .primary {
                    style._apply(to: &shape)
                } else {
                    style.offset(by: Int(id.rawValue))._apply(to: &shape)
                }
            }
        }
    }
}


// MARK: - ContentStyle.ID + Extension

extension SystemColorType {
    package init(_ id: ContentStyle.ID) {
        switch id {
        case .primary: self = .primary
        case .secondary: self = .secondary
        case .tertiary: self = .tertiary
        case .quaternary: self = .quaternary
        case .quinary: self = .quinary
        }
    }
}

extension Color {
    package init(_ id: ContentStyle.ID) {
        switch id {
        case .primary: self = .primary
        case .secondary: self = .secondary
        case .tertiary: self = .tertiary
        case .quaternary: self = .quaternary
        case .quinary: self = .quinary
        }
    }
}

// MARK: - ContentStyle.ID + ColorProvider

extension ContentStyle.ID: ColorProvider {
    package func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        SystemColorType(self).resolve(in: environment)
    }

    package var level: Int {
        Int(rawValue)
    }

    package init?(level: Int) {
        self.init(rawValue: Int8(level & 0xFF))
    }

    package init(truncatingLevel level: Int) {
        switch level {
        case 0: self = .primary
        case 1: self = .secondary
        case 2: self = .tertiary
        case 3: self = .quaternary
        default: self = .quinary
        }
    }
}

// MARK: - ShapeStyle + HierarchicalShapeStyleModifier

extension ShapeStyle {
    /// Returns the second level of this shape style.
    @_alwaysEmitIntoClient
    public var secondary: some ShapeStyle {
        HierarchicalShapeStyleModifier(base: self, level: 1)
    }

    /// Returns the third level of this shape style.
    @_alwaysEmitIntoClient
    public var tertiary: some ShapeStyle {
        HierarchicalShapeStyleModifier(base: self, level: 2)
    }

    /// Returns the fourth level of this shape style.
    @_alwaysEmitIntoClient
    public var quaternary: some ShapeStyle {
        HierarchicalShapeStyleModifier(base: self, level: 3)
    }

    /// Returns the fifth level of this shape style.
    @_alwaysEmitIntoClient
    public var quinary: some ShapeStyle {
        HierarchicalShapeStyleModifier(base: self, level: 4)
    }
}

// MARK: - HierarchicalShapeStyleModifier

/// Styles that you can apply to hierarchical shapes.
@frozen
public struct HierarchicalShapeStyleModifier<Base>: ShapeStyle where Base: ShapeStyle {
    @usableFromInline
    var base: Base

    @usableFromInline
    var level: Int

    @_alwaysEmitIntoClient
    init(base: Base, level: Int) {
        (self.base, self.level) = (base, level)
    }

    public func _apply(to shape: inout _ShapeStyle_Shape) {
        if let primaryStyle = primaryStyle(in: shape.environment) {
            primaryStyle.offset(by: level)._apply(to: &shape)
        } else {
            base.offset(by: level)._apply(to: &shape)
        }
    }

    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        type.result = .bool(true)
    }

    public typealias Resolved = Never
}
