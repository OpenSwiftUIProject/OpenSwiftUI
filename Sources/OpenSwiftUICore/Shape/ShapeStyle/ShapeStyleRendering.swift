//
//  ShapeStyleRendering.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: WIP
//  ID: 3890C65F12EA82A4BC5FBD33046B67FA (SwiftUICore)

extension ShapeStyle {
    package typealias RenderedShape = _ShapeStyle_RenderedShape
    package typealias RenderedLayers = _ShapeStyle_RenderedLayers
    package typealias LayerID = _ShapeStyle_LayerID
    package typealias InterpolatorGroup = _ShapeStyle_InterpolatorGroup
}

package struct _ShapeStyle_RenderedShape {
    package enum Shape {
        case empty
        case path(Path, FillStyle)
        case text(StyledTextContentView)
        case image(GraphicsImage)
        case alphaMask(DisplayList.Item)
    }
}

package struct _ShapeStyle_RenderedLayers {
}

package enum _ShapeStyle_LayerID: Equatable {
    case unstyled
    case styled(_ShapeStyle_Name, UInt16)
    case customStyle(Swift.UInt32)
    case named(String?)
}

final package class _ShapeStyle_InterpolatorGroup/*: DisplayList.InterpolatorGroup*/ {
    struct Layer {
        let id: ShapeStyle.LayerID

        let serial: UInt32

        var style: ShapeStyle.Pack.Style

        var state: DisplayList.InterpolatorLayer

        var isRemoved:Bool
    }

    var layers: [Layer] = []

    var contentsScale: Float = .zero

    // FIXME
    var rasterizationOptions: RasterizationOptions = .init()

    var serial: UInt32 = .zero

    var cursor: Int32 = .zero

    init() {
        _openSwiftUIEmptyStub()
    }
}

extension DisplayList {
    struct InterpolatorLayer {}
}
