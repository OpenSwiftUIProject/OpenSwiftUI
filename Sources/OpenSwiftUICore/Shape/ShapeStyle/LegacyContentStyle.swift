//
//  LegacyContentStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

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
