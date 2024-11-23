//
//  HierarchicalShapeStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by OffsetShapeStyle, SeparatorShapeStyle and BackgroundMaterial

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
    
    package static let sharedPrimary: AnyShapeStyle = .init(HierarchicalShapeStyle.primary)
    
    package var level: Int {
        Int(id)
    }
    
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        if case .primaryStyle = shape.operation {
            shape.result = .style(HierarchicalShapeStyle.sharedPrimary)
        } else {
            if shape.activeRecursiveStyles.contains(.content) {
                LegacyContentStyle.sharedPrimary._apply(to: &shape)
            } else {
                shape.activeRecursiveStyles.formUnion(.content)
                if let foregroundStyle = shape.foregroundStyle ?? shape.currentForegroundStyle {
                    let style = foregroundStyle.primaryStyle(in: shape.environment) ?? foregroundStyle
                    if id == 0 {
                        if case let .copyStyle(name: name) = shape.operation {
                            shape.result = .style(style)
                        } else {
                            style._apply(to: &shape)
                        }
                    } else {
                        if case let .copyStyle(name: name) = shape.operation {
                            // shape.result = .style(OffsetShapeStyle(style, id))
                        } else {
                            // OffsetShapeStyle(style, id)._apply(to: &shape)
                        }
                    }
                } else {
                    switch shape.role {
                        case .separator:
                            // SeparatorShapeStyle._apply(to: shape)
                            break
                        default:
                            // shape.environment.backgroundMaterial
                            break
                    }
                }
                shape.activeRecursiveStyles.subtract(.content)
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
