//
//  ShapeStyleRendering.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 3890C65F12EA82A4BC5FBD33046B67FA (SwiftUICore)

package import OpenAttributeGraphShims
package import OpenCoreGraphicsShims
import OpenRenderBoxShims

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
            if contentView.text.needsStyledRendering {
                renderKeyedText(
                    contentView,
                    style: styles.value[name, 0],
                    name: name,
                    layers: &layers
                )
            } else {
                renderUnstyledText(contentView, layers: &layers)
            }
        case let .image(graphicsImage):
            if graphicsImage.isTemplate {
                if case let .vectorGlyph(glyph) = graphicsImage.contents {
                    renderVectorGlyph(
                        glyph,
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
            item.frame = frame
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
        // FIXME
        for effect in style.effects {
            guard case let .shadow(shadow) = effect.kind else {
                continue
            }
            addEffect(.filter(.shadow(shadow)))
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
            var image = graphicsImage
            image.maskColor = color
            item.value = .content(DisplayList.Content(
                .image(image),
                seed: contentSeed
            ))
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

    private mutating func renderVectorGlyph(
        _ glyph: ResolvedVectorGlyph,
        size: CGSize,
        orientation: Image.Orientation,
        name: ShapeStyle.Name,
        styles: ShapeStyle.Pack,
        layers: inout ShapeStyle.RenderedLayers
    ) {
        func level(for style: ORBSymbolStyle) -> Int? {
            switch style {
            case .primary: 0
            case .secondary: 1
            case .tertiary: 2
            case .quaternary: 3
            case .quinary: 4
            default: nil
            }
        }

        let slice = styles[name]
        var flags: ORBSymbolUpdateFlags
        switch orientation {
        case .up: flags = []
        case .upMirrored: flags = [.flipX]
        case .down: flags = [.flipX, .flipY]
        case .downMirrored: flags = [.flipY]
        case .left: flags = [.swapAxes]
        case .leftMirrored: flags = [.swapAxes, .flipX]
        case .right: flags = [.swapAxes, .flipX, .flipY]
        case .rightMirrored: flags = [.swapAxes, .flipY]
        }
        flags.insert(.mergeLayers)
        if !glyph.preservesVectorRepresentation {
            flags.insert(.applyVerticalOffset)
        }
        var position = frame.origin
        var size = frame.size
        let update = glyph.animator.beginUpdate(
            with: .unspecified,
            position: &position,
            size: &size,
            flags: flags
        )
        defer { glyph.animator.end(update) }
        let nextTime = update.nextTime
        var imageScale = 1.0
        var imageOpacity: Float = 1.0
        if !glyph.preservesVectorRepresentation,
           !slice.isEmpty,
           let image = update.templateImage(scale: &imageScale, opacity: &imageOpacity) {
            shape = .image(GraphicsImage(
                contents: .cgImage(image),
                scale: imageScale,
                unrotatedPixelSize: CGSize(width: image.width, height: image.height),
                orientation: orientation,
                isTemplate: true
            ))
            let style = slice[0].applyingOpacity(imageOpacity)
            layers.beginLayer(id: .styled(name, 0), style: style, shape: &self)
            render(style: style)
            layers.endLayer(shape: &self)
            return
        }

        let groupCount = update.groupCount
        // Style-mask bit 12 disables the single-layer path. Its meaning is not known.
        let isSingleLayer = update.styleMask & (1 << 12) == 0
            && groupCount == 1 && update.groupSize(group: 0) == 1
        if !isSingleLayer, slice.allColors {
            let list = ORBDisplayList()
            update.draw(in: list.state) { symbolStyle, colorName in
                let color: Color.Resolved?
                if let level = level(for: symbolStyle), !slice.isEmpty {
                    color = slice[min(level, slice.count - 1)].color
                } else if symbolStyle == .namedColor {
                    color = colorName.flatMap { styles[$0] }
                } else {
                    color = nil
                }
                guard let color else { return .null }
                return ORBColor(red: color.red, green: color.green, blue: color.blue, alpha: color.opacity)
            }
            layers.beginLayer(id: .unstyled, style: nil, shape: &self)
            item = makeDrawingItem(
                from: list.moveContents(),
                offset: CGSize(item.frame.origin),
                flags: []
            )
            if nextTime.isFinite {
                layerNeedes.insert(.drawingGroup)
            }
            layers.endLayer(shape: &self)
            return
        }

        var drawingList: ORBDisplayList?
        for group in 0 ..< groupCount {
            for index in 0 ..< update.groupSize(group: group) {
                let layer = ORBSymbolUpdateLayer(update: update, group: group, index: index)
                let opacity = layer.drawingOpacity
                guard opacity > 0 else { continue }
                let style: ShapeStyle.Pack.Style
                let id: ShapeStyle.LayerID
                if let level = level(for: layer.style), !slice.isEmpty {
                    style = slice[min(level, slice.count - 1)].applyingOpacity(opacity)
                    id = .styled(name, UInt16(level))
                } else if layer.style == .namedColor, let colorName = layer.colorName {
                    let color: Color.Resolved
                    if let resolved = styles[colorName] {
                        color = resolved
                    } else if let proposed = layer.defaultColor {
                        color = Color.Resolved(failableCGColor: proposed) ?? .clear
                    } else {
                        continue
                    }
                    style = ShapeStyle.Pack.Style(.color(color)).applyingOpacity(opacity)
                    id = .named(colorName)
                } else {
                    continue
                }
                layers.beginLayer(id: id, style: style, shape: &self)
                var transform = CGAffineTransform()
                let path = glyph.preservesVectorRepresentation
                    ? ORBPath.null
                    : layer.path(transform: &transform, flags: [.includeClips])
                if !path.isNull {
                    // Layer paths belong to the update; the shape takes an owned copy.
                    shape = .path(
                        Path(box: Path.PathBox(takingPath: path.copy(transform: &transform))),
                        FillStyle()
                    )
                } else {
                    let list: ORBDisplayList
                    if let drawingList {
                        list = drawingList
                    } else {
                        list = ORBDisplayList()
                        drawingList = list
                    }
                    layer.draw(
                        in: list.state,
                        color: .white,
                        opacity: 1,
                        blendMode: .init(rawValue: 0),
                        flags: [.includeClips]
                    )
                    shape = .alphaMask(makeDrawingItem(
                        from: list.moveContents(),
                        offset: .zero,
                        flags: [.alphaOnly]
                    ))
                    if nextTime.isFinite {
                        layerNeedes.insert(.drawingGroup)
                    }
                }
                render(style: style)
                layers.endLayer(shape: &self)
            }
        }
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

    private mutating func renderKeyedText(
        _ text: StyledTextContentView,
        style: ShapeStyle.Pack.Style,
        name: ShapeStyle.Name,
        layers: inout ShapeStyle.RenderedLayers
    ) {
        #if os(macOS)
        // Font smoothing on macOS depends on the fill color, even in an alpha-only context.
        // See https://developer.apple.com/documentation/coregraphics/cgcontext/setshouldsmoothfonts(_:)
        let maskColor: ORBColor
        switch style.fill {
        case let .color(color):
            maskColor = ORBColor(
                red: color.linearRed,
                green: color.linearGreen,
                blue: color.linearBlue,
                alpha: 1
            )
        default:
            maskColor = environment.colorScheme == .dark ? .white : .black
        }
        #else
        let maskColor = ORBColor.white
        #endif
        let resolved = text.text
        let textLayers = resolved.layers(
            for: frame.size,
            renderer: text.renderer,
            deviceScale: environment.displayScale
        )
        let offset = resolved.frameOffset()
        var flags: RasterizationOptions.Flags = text.needsDrawingGroup ? .isAccelerated : []
        if text.renderer != nil {
            flags.insert(.highRes)
        }
        if let unstyled = textLayers.unstyled {
            let drawing = makeDrawingItem(from: unstyled, offset: offset, flags: flags)
            layers.beginLayer(id: .unstyled, style: nil, shape: &self)
            item.value = drawing.value
            item.frame.origin += CGSize(drawing.frame.origin)
            item.frame.size = drawing.frame.size
            layers.endLayer(shape: &self)
        }
        let transform = ORBDisplayListTransform()
        func drawStyled(
            list: any ORBDisplayListContents,
            id: ShapeStyle.LayerID,
            style: ShapeStyle.Pack.Style,
            keyColor: ORBColor
        ) {
            transform.removeAll()
            transform.addColorReplacement(from: keyColor, to: maskColor, colorSpace: .linearSRGB)
            let mask = transform.copyApplying(toDisplayList: list)
            let drawing = makeDrawingItem(from: mask, offset: offset, flags: flags.union(.alphaOnly))
            layers.beginLayer(id: id, style: style, shape: &self)
            shape = .alphaMask(drawing)
            render(style: style)
            layers.endLayer(shape: &self)
        }
        for (index, list) in textLayers.custom.reversed() {
            drawStyled(
                list: list,
                id: .customStyle(UInt32(truncatingIfNeeded: index)),
                style: resolved.styles[index],
                keyColor: ORBColor(red: -1, green: -1, blue: Float(index) / 1024, alpha: ORBColor.invalidComponent)
            )
        }
        if let foreground = textLayers.foreground {
            drawStyled(
                list: foreground,
                id: .styled(name, 0),
                style: style,
                keyColor: .foregroundKeyColorAnyAlpha
            )
        }
    }

    private func makeDrawingItem(
        from list: any ORBDisplayListContents,
        offset: CGSize,
        flags: RasterizationOptions.Flags
    ) -> DisplayList.Item {
        let bounds = list.boundingRect
        let rect = (bounds.isNull ? CGRect.zero : bounds).integral
        return DisplayList.Item(
            .content(DisplayList.Content(
                .drawing(list, rect.origin, RasterizationOptions(flags: flags.union(.defaultFlags))),
                seed: contentSeed
            )),
            frame: rect.offset(by: offset),
            identity: .none,
            version: item.version
        )
    }

    private mutating func renderUnstyledText(
        _ text: StyledTextContentView,
        layers: inout ShapeStyle.RenderedLayers
    ) {
        let resolved = text.text
        let renderer = text.renderer
        layers.beginLayer(
            id: .unstyled,
            style: nil,
            shape: &self
        )
        item.frame = resolved.frame(in: frame.size, renderer: renderer)
            .offset(by: CGSize(frame.origin))
        if resolved.needsRBDisplayList {
            _openSwiftUIUnimplementedFailure()
        } else {
            item.value = .content(DisplayList.Content(
                .text(text, frame.size),
                seed: contentSeed
            ))
        }
        layers.endLayer(shape: &self)
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
        defer { layers = .empty }
        switch layers {
        case .empty:
            return .init()
        case let .item(item):
            let displayList = DisplayList(item)
            return displayList
        case let .items(items):
            let displayList = DisplayList(items)
            var item = DisplayList.Item(
                .effect(.identity, displayList),
                frame: shape.frame,
                identity: shape.item.identity,
                version: shape.item.version
            )
            item.canonicalize(options: options)
            return DisplayList(item)
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
        var newItem = shape.commitItem()
        switch layers {
        case .empty:
            layers = .item(newItem)
        case let .item(item):
            var oldItem = item
            let offset = CGSize(shape.frame.origin)
            oldItem.frame.origin -= offset
            oldItem.identity = .none
            newItem.frame.origin -= offset
            newItem.identity = .none
            layers = .items([
                oldItem,
                newItem,
            ])
        case let .items(items):
            var items = items
            let offset = CGSize(shape.frame.origin)
            newItem.frame.origin -= offset
            newItem.identity = .none
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

    override func nextUpdate(after time: Time) -> Time {
        var nextUpdate = Time.infinity
        for layer in layers {
            nextUpdate.formMin(layer.state.nextUpdate(after: time))
        }
        return nextUpdate
    }
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
