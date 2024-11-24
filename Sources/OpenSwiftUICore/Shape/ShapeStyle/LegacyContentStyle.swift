//
//  LegacyContentStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

package struct LegacyContentStyle: ShapeStyle, PrimitiveShapeStyle {
    package static let sharedPrimary: AnyShapeStyle = {
        // Blocked by Color
        preconditionFailure("TODO")
    }()
    
    package var id: ContentStyle.ID
    package var color: Color
    
    package func _apply(to shape: inout _ShapeStyle_Shape) {
        preconditionFailure("TODO")
    }
}
