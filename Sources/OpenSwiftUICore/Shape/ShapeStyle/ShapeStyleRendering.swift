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

        static let drawingGroup: LayerNeeds = .init(rawValue: 1 << 0)
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
        defer {
            blendMode = .normal
            opacity = 1.0
            layerNeedes = []
            item.value = .empty
        }
        guard opacity != .zero, !frame.isEmpty else {
            item.value = .empty
            if let data = interpolatorData {
                addEffect(.interpolatorLayer(data.group, serial: data.serial))
                interpolatorData = nil
            }
            return item
        }
        item.canonicalize(options: options)
        if let data = interpolatorData {
            addEffect(.interpolatorLayer(data.group, serial: data.serial))
            interpolatorData = nil
        }
        if layerNeedes.contains(.drawingGroup) {
            item.addDrawingGroup(contentSeed: contentSeed)
        }
        if blendMode != .blendMode(.normal) {
            addEffect(.blendMode(blendMode))
        }
        if opacity != 1.0 {
            addEffect(.opacity(opacity))
        }
        return item
    }

    package mutating func background(_ other: inout ShapeStyle.RenderedShape) {
        _openSwiftUIUnimplementedFailure()
    }

    private mutating func addEffect(_ effect: DisplayList.Effect) {
        let effectItem = DisplayList.Item(
            item.value,
            frame: CGRect(origin: .zero, size: item.size),
            identity: .none,
            version: item.version
        )
        item.value = .effect(effect, DisplayList(effectItem))
        item.canonicalize(options: options)
    }

    private mutating func render(style: ShapeStyle.Pack.Style) {
        blendMode = style.blend
        opacity = opacity * style.opacity
        switch style.fill {
        case let .color(resolved):
            var resolved  = resolved
            if style.effects.isEmpty {
                resolved.opacity =  opacity * resolved.opacity
                opacity = 1.0
            }
            render(color: resolved)
        default:
            _openSwiftUIUnimplementedFailure()
        }
        _openSwiftUIUnimplementedWarning()
    }

    private mutating func render(color: Color.Resolved) {
        defer {
            if let data = interpolatorData {
                addEffect(.interpolatorLayer(data.group, serial: data.serial))
                interpolatorData = nil
            }
        }
        guard !color.isClear else { return }
        switch shape {
        case let .path(path, fillStyle):
            if let rect = path.rect() {
                item.value = .content(DisplayList.Content(
                    .color(color),
                    seed: contentSeed
                ))
                item.frame.origin.x += rect.origin.x
                item.frame.origin.y += rect.origin.y
                item.frame.size = rect.size
            } else {
                item.value = .content(DisplayList.Content(
                    .shape(path, _AnyResolvedPaint(color), fillStyle),
                    seed: contentSeed
                ))
            }
        case .text:
            item.value = .content(DisplayList.Content(
                .color(.clear),
                seed: contentSeed
            ))
        case let .image(graphicsImage):
            // TODO: Blocked by ImagePaint
            _ = graphicsImage
            _openSwiftUIUnimplementedFailure()
        case let .alphaMask(maskItem):
            let offset = item.frame.origin
            item.frame = maskItem.frame.offsetBy(dx: offset.x, dy: offset.y)
            item.value = maskItem.value
            if color != .white {
                addEffect(.filter(.colorMultiply(color)))
            }
        case .empty:
            break
        }
    }

    private mutating func render(paint: AnyResolvedPaint) {
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

    private mutating func renderUnstyledText(
        _ text: StyledTextContentView,
        layers: inout ShapeStyle.RenderedLayers
    ) {
        _openSwiftUIUnimplementedFailure()
    }
}

package struct _ShapeStyle_RenderedLayers {
    var group: ShapeStyle.InterpolatorGroup?

    private enum Layers {
        case empty
        case item(DisplayList.Item)
        case items([DisplayList.Item])
    }

    private var layers: Layers = .empty

    init(group: ShapeStyle.InterpolatorGroup?) {
        self.group = group
    }

    mutating func commit(
        shape: inout ShapeStyle.RenderedShape,
        options: DisplayList.Options
    ) -> DisplayList {
        if let group {
            _openSwiftUIUnimplementedWarning()
        }
        switch layers {
        case .empty:
            return .init()
        case let .item(item):
            let displayList = DisplayList(item)
            layers = .empty
            return displayList
        case let .items(items):
            let displayList = DisplayList(items)
            _openSwiftUIUnimplementedFailure()
            layers = .empty
        }
    }

    mutating func beginLayer(
        id: ShapeStyle.LayerID,
        style: ShapeStyle.Pack.Style?,
        shape: inout ShapeStyle.RenderedShape
    ) {
        guard let group else {
            return
        }
        // FIXME
        guard case let .interpolatorData(group: group, serial: serial) = group.addLayer(id: id, style: style) else {
            _openSwiftUIUnimplementedWarning()
            return
        }
//        shape.interpolatorData = (group, serial)
        _openSwiftUIUnimplementedWarning()
    }

    mutating func endLayer(shape: inout ShapeStyle.RenderedShape) {
        let newItem = shape.commitItem()
        switch layers {
        case .empty:
            layers = .item(newItem)
        case let .item(item):
            var oldItem = item
            let offset = CGSize(shape.frame.origin)
            oldItem.frame.origin -= offset
            layers = .items([
                oldItem,
                newItem,
            ])
        case let .items(items):
            var items = items
            // TODO
            let offset = CGSize(shape.frame.origin)
            items[0].frame.origin -= offset
            items.append(newItem)
            layers = .items(items)
        }
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

    fileprivate enum AddLayerResult {
        case interpolatorData(group: DisplayList.InterpolatorGroup, serial: UInt32)
        case none // FIXME
    }

    fileprivate func addLayer(
        id: ShapeStyle.LayerID,
        style: ShapeStyle.Pack.Style?
    ) -> AddLayerResult {
        _openSwiftUIUnimplementedWarning()
        return .interpolatorData(group: .init(), serial: 0)
    }
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
