//
//  ShapeStyleRendering.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 3890C65F12EA82A4BC5FBD33046B67FA (SwiftUICore)

package import OpenAttributeGraphShims
package import OpenCoreGraphicsShims

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

    var shape: ShapeStyle.RenderedShape.Shape

    var contentSeed: DisplayList.Seed

    var frame: CGRect

    var interpolatorData: (group: DisplayList.InterpolatorGroup, serial: UInt32)?

    var item: DisplayList.Item

    var options: DisplayList.Options

    @Attribute var environment: EnvironmentValues

    var blendMode: GraphicsBlendMode = .normal

    var opacity: Float

    private struct LayerNeeds: OptionSet {
        let rawValue: UInt8
    }

    private var layerNeedes: LayerNeeds

    package init(
        _ shape: ShapeStyle.RenderedShape.Shape,
        frame: CGRect,
        identity: DisplayList.Identity,
        version: DisplayList.Version,
        contentSeed: DisplayList.Seed,
        options: DisplayList.Options,
        environment: Attribute<EnvironmentValues>
    ) {
        self.shape = shape
        self.contentSeed = contentSeed
        self.frame = frame
        self.interpolatorData = nil
        self.item = .init(
            .empty,
            frame: frame,
            identity: identity,
            version: version
        )
        self.options = options
        self._environment = environment
        self.blendMode = .normal
        self.opacity = 1.0
        self.layerNeedes = []
    }

    package mutating func renderItem(
        name: ShapeStyle.Name,
        styles: Attribute<ShapeStyle.Pack>,
        layers: inout ShapeStyle.RenderedLayers
    ) {
        switch shape {
        case let .text(contentView):
            // Text rendering
            _ = contentView
            _openSwiftUIUnimplementedWarning()
            break
        case let .image(graphicsImage):
            if graphicsImage.isTemplate {
                if case let .vectorGlyph(glygh) = graphicsImage.contents {
                    renderVectorGlyph(
                        glygh,
                        size: graphicsImage.size,
                        orientation: graphicsImage.orientation,
                        name: name,
                        styles: styles.value,
                        layers: &layers
                    )
                } else {
                    let style = styles.value[name, 0]
                    layers.beginLayer(
                        id: .styled(name, 0),
                        style: style,
                        shape: &self
                    )
                    render(style: style)
                    layers.endLayer(shape: &self)
                }
            } else {
                renderUnstyledImage(graphicsImage, layers: &layers)
            }
        case .path, .alphaMask:
            let style = styles.value[name, 0]
            layers.beginLayer(
                id: .styled(name, 0),
                style: style,
                shape: &self
            )
            render(style: style)
            layers.endLayer(shape: &self)
        case .empty:
            break
        }
    }

    package mutating func commitItem() -> DisplayList.Item {
        _openSwiftUIUnimplementedFailure()
    }

    package mutating func background(_ other: inout ShapeStyle.RenderedShape) {
        _openSwiftUIUnimplementedFailure()
    }

    private func render(style: ShapeStyle.Pack.Style) {
        _openSwiftUIUnimplementedFailure()
    }

    private func renderVectorGlyph(
        _ glyph: ResolvedVectorGlyph,
        size: CGSize,
        orientation: Image.Orientation,
        name: ShapeStyle.Name,
        styles: ShapeStyle.Pack,
        layers: inout ShapeStyle.RenderedLayers
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    private mutating func renderUnstyledImage(
        _ graphicsImage: GraphicsImage,
        layers: inout ShapeStyle.RenderedLayers
    ) {
        layers.beginLayer(
            id: .unstyled,
            style: nil,
            shape: &self
        )
        item.value = .content(DisplayList.Content(
            .image(graphicsImage),
            seed: contentSeed
        ))
        layers.endLayer(shape: &self)
    }
}

package struct _ShapeStyle_RenderedLayers {
    var group: ShapeStyle.InterpolatorGroup?

    private enum Layers {
        case empty
        case item(DisplayList.Item)
        case itesm([DisplayList.Item])
    }

    private var layers: Layers = .empty

    init(group: ShapeStyle.InterpolatorGroup?) {
        self.group = group
    }

    func commit(
        shape: inout ShapeStyle.RenderedShape,
        options: DisplayList.Options
    ) -> DisplayList {
        _openSwiftUIUnimplementedFailure()
    }

    func beginLayer(
        id: ShapeStyle.LayerID,
        style: ShapeStyle.Pack.Style?,
        shape: inout ShapeStyle.RenderedShape
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    func endLayer(shape: inout ShapeStyle.RenderedShape) {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - _ShapeStyle_LayerID

package enum _ShapeStyle_LayerID: Equatable {
    case unstyled
    case styled(ShapeStyle.Name, UInt16)
    case customStyle(UInt32)
    case named(String?)
}

final package class _ShapeStyle_InterpolatorGroup: DisplayList.InterpolatorGroup {
    private struct Layer {
        let id: ShapeStyle.LayerID
        let serial: UInt32
        var style: ShapeStyle.Pack.Style
        var state: DisplayList.InterpolatorLayer
        var isRemoved:Bool
    }

    private var layers: [Layer] = []

    var contentsScale: Float = .zero

    // FIXME
    var rasterizationOptions: RasterizationOptions = .init()

    var serial: UInt32 = .zero

    var cursor: Int32 = .zero

//    init() {
//        _openSwiftUIEmptyStub()
//    }
}

extension DisplayList {
    struct InterpolatorLayer {}
}


extension ShapeStyle.Pack.Style {
    package func draw(
        _ path: Path,
        style: PathDrawingStyle,
        in ctx: GraphicsContext,
        bounds: CGRect?
    ) {
        _openSwiftUIUnimplementedFailure()
    }
}
