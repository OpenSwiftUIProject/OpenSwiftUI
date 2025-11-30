//
//  ShapeStyle_RenderedShape.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: WIP
//  ID: 3890C65F12EA82A4BC5FBD33046B67FA (?)

extension ShapeStyle {
    package typealias RenderedShape = _ShapeStyle_RenderedShape
    package typealias InterpolatorGroup = _ShapeStyle_InterpolatorGroup
}

package struct _ShapeStyle_RenderedShape {
    package enum Shape {
        case empty
        case path(Path, FillStyle)
        case text(StyledTextContentView)
        // case image(GraphicsImage)
        case alphaMask(DisplayList.Item)
    }
}

final package class _ShapeStyle_InterpolatorGroup/*: DisplayList.InterpolatorGroup*/ {
}
