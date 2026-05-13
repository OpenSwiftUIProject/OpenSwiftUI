//
//  DisplayListViewPlatform.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by GraphicsContext and Platform
//  ID: 8BBC66CBE42B8A65F8A2F3799C81A349 (SwiftUICore)

public import OpenQuartzCoreShims
import Foundation
import OpenSwiftUI_SPI
#if canImport(QuartzCore)
import QuartzCore_Private
#endif

// MARK: - PlatformViewDefinition

@_spi(DisplayList_ViewSystem)
@available(OpenSwiftUI_v6_0, *)
open class PlatformViewDefinition: @unchecked Sendable {
    public struct System: Hashable, Sendable {
        public static let uiView = PlatformViewDefinition.System(base: .uiView)
        public static let nsView = PlatformViewDefinition.System(base: .nsView)
        static let caLayer = PlatformViewDefinition.System(base: .caLayer)

        var base: ViewSystem
    }
    
    public enum ViewKind: Sendable {
        case inherited
        case color
        case image
        case shape
        case shadow
        case backdrop
        case chameleonColor
        case drawing
        case compositing
        case geometry
        case projection
        case affine3D
        case mask
        case platformView
        case platformGroup
        case platformLayer
        case platformEffect
        
        public var isContainer: Bool {
            switch self {
            case .inherited, .compositing, .geometry, .projection, .affine3D, .mask, .platformGroup, .platformEffect:
                return true
            case .color, .image, .shape, .shadow, .backdrop, .chameleonColor, .drawing, .platformView, .platformLayer:
                return false
            }
        }
    }
  
    open class var system: PlatformViewDefinition.System { .init(base: .caLayer) }
    #if os(visionOS) // TODO: VWT alignment issue when running for Designed for iPad
    open class func makeView(kind: PlatformViewDefinition.ViewKind, item: Any) -> AnyObject { _openSwiftUIBaseClassAbstractMethod() }
    #endif
    open class func makeView(kind: PlatformViewDefinition.ViewKind) -> AnyObject { _openSwiftUIBaseClassAbstractMethod() }
    open class func makeLayerView(type: CALayer.Type, kind: PlatformViewDefinition.ViewKind) -> AnyObject { _openSwiftUIBaseClassAbstractMethod() }
    open class func makePlatformView(view: AnyObject, kind: PlatformViewDefinition.ViewKind) { _openSwiftUIBaseClassAbstractMethod() }
    open class func makeDrawingView(options: PlatformDrawableOptions) -> any PlatformDrawable { _openSwiftUIBaseClassAbstractMethod() }
    open class func setPath(_ path: Path, shapeView: AnyObject) { _openSwiftUIBaseClassAbstractMethod() }
    open class func setProjectionTransform(_ transform: ProjectionTransform, projectionView: AnyObject) { _openSwiftUIBaseClassAbstractMethod() }
    open class func getRBLayer(drawingView: AnyObject) -> AnyObject? { _openSwiftUIBaseClassAbstractMethod() }
    open class func setIgnoresEvents(_ state: Bool, of view: AnyObject) { _openSwiftUIBaseClassAbstractMethod() }
    open class func setAllowsWindowActivationEvents(_ value: Bool?, for view: AnyObject) { _openSwiftUIBaseClassAbstractMethod() }
    open class func setHitTestsAsOpaque(_ value: Bool, for view: AnyObject) { _openSwiftUIBaseClassAbstractMethod() }
}

// MARK: - DisplayList.ViewUpdater.Platform Definition

extension DisplayList.ViewUpdater {
    package struct Platform {
        let rawValue: UInt

        struct State {
            var position: CGPoint = .infinity
            var size: CGSize = .infinity
            let kind: PlatformViewDefinition.ViewKind
            var flags: ViewFlags = []
            var platformState: Platform.PlatformState = .init()
            
            mutating func reset() {
                position = .infinity
                size = .infinity
                flags = []
            }

            @inline(__always)
            var isBoundsOriginEnabled: Bool {
                get { flags.contains(.boundsOrigin) }
                set {
                    if newValue {
                        flags.insert(.boundsOrigin)
                    } else {
                        flags.remove(.boundsOrigin)
                    }
                }
            }

            @inline(__always)
            var isAffineTransformEnabled: Bool {
                get { flags.contains(.affineTransform) }
                set {
                    if newValue {
                        flags.insert(.affineTransform)
                    } else {
                        flags.remove(.affineTransform)
                    }
                }
            }

            @inline(__always)
            var isProjectionGeometryEnabled: Bool {
                get { flags.contains(.projectionGeometry) }
                set {
                    if newValue {
                        flags.insert(.projectionGeometry)
                    } else {
                        flags.remove(.projectionGeometry)
                    }
                }
            }

            @inline(__always)
            var isClipRectEnabled: Bool {
                get { flags.contains(.clipRect) }
                set {
                    if newValue {
                        flags.insert(.clipRect)
                    } else {
                        flags.remove(.clipRect)
                    }
                }
            }

            @inline(__always)
            var isMaskLayerEnabled: Bool {
                get { flags.contains(.maskLayer) }
                set {
                    if newValue {
                        flags.insert(.maskLayer)
                    } else {
                        flags.remove(.maskLayer)
                    }
                }
            }
        }

        struct ViewFlags: OptionSet {
            let rawValue: UInt8
            
            @inline(__always)
            static var boundsOrigin: ViewFlags { .init(rawValue: 1 << 0) }
            
            @inline(__always)
            static var affineTransform: ViewFlags { .init(rawValue: 1 << 1) }
            
            @inline(__always)
            static var projectionGeometry: ViewFlags { .init(rawValue: 1 << 2) }
            
            @inline(__always)
            static var clipRect: ViewFlags { .init(rawValue: 1 << 3) }
            
            @inline(__always)
            static var maskLayer: ViewFlags { .init(rawValue: 1 << 4) }
        }
    }
}

// MARK: - DisplayList.ViewUpdater.Platform API [WIP]

extension DisplayList.ViewUpdater.Platform {
    package init(definition: PlatformViewDefinition.Type) {
        self.init(rawValue: UInt(bitPattern: ObjectIdentifier(definition)) | UInt(definition.system.base.rawValue))
    }
    
    @inline(__always)
    var definition: PlatformViewDefinition.Type {
        return unsafeBitCast(rawValue & ~3, to: PlatformViewDefinition.Type.self)
    }

    @inline(__always)
    var viewSystem: ViewSystem {
        return unsafeBitCast(UInt8(rawValue & 3), to: ViewSystem.self)
    }

    package func viewLayer(_ view: AnyObject) -> CALayer {
        #if canImport(QuartzCore)
        CoreViewLayer(system: viewSystem, view: view)
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
    
    @inline(__always)
    package func subviews(_ view: AnyObject) -> [AnyObject] {
        #if canImport(QuartzCore)
        CoreViewSubviews(system: viewSystem, view: view) as [AnyObject]
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
    
    @inline(__always)
    package func removeFromSuperview(_ view: AnyObject) {
        #if canImport(QuartzCore)
        CoreViewRemoveFromSuperview(system: viewSystem, view: view)
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }

    @inline(__always)
    package func addSubview(_ child: AnyObject, to parent: AnyObject, at index: Int) {
        #if canImport(QuartzCore)
        CoreViewAddSubview(
            system: viewSystem,
            parent: parent,
            child: child,
            index: UInt(index)
        )
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }

    @inline(__always)
    package func setFrame(_ frame: CGRect, of view: AnyObject) {
        #if canImport(QuartzCore)
        CoreViewSetFrame(system: viewSystem, view: view, frame: frame)
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }

    @inline(__always)
    package func frame(of view: AnyObject) -> CGRect? {
        #if canImport(QuartzCore)
        CoreViewGetFrame(system: viewSystem, view: view)
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }

    @inline(__always)
    package func bounds(of view: AnyObject) -> CGRect? {
        #if canImport(Darwin)
        view.bounds
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }

    @inline(__always)
    package func maskView(_ view: AnyObject) -> AnyObject? {
        #if canImport(QuartzCore)
        CoreViewMaskView(system: viewSystem, view: view) as AnyObject?
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }

    @inline(__always)
    package func setClipsToBounds(_ clips: Bool, of view: AnyObject, onLayer: Bool) {
        #if canImport(QuartzCore)
        CoreViewSetClipsToBounds(
            system: viewSystem,
            view: view,
            clips: clips,
            onLayer: onLayer
        )
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }

    @inline(__always)
    package func setGeometry(
        of view: AnyObject,
        useViewAPIs: Bool,
        positionChanged: Bool,
        boundsOriginChanged: Bool,
        boundsSizeChanged: Bool,
        position: CGPoint,
        bounds: CGRect
    ) {
        #if canImport(QuartzCore)
        CoreViewSetGeometry(
            system: viewSystem,
            view: view,
            useViewAPIs: useViewAPIs,
            positionChanged: positionChanged,
            boundsOriginChanged: boundsOriginChanged,
            boundsSizeChanged: boundsSizeChanged,
            position: position,
            bounds: bounds
        )
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }

    @inline(__always)
    package func setMaskGeometry(of view: AnyObject, bounds: CGRect) {
        #if canImport(QuartzCore)
        CoreViewSetMaskGeometry(system: viewSystem, view: view, bounds: bounds)
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }
    
    package func setShadow(_ shadow: ResolvedShadowStyle?, layer: CALayer) {
        #if canImport(QuartzCore)
        if let shadow {
            if viewSystem != .caLayer, let delegate = layer.delegate {
                let view = delegate as AnyObject
                CoreViewSetShadow(
                    system: CoreViewResolvedSystem(system: viewSystem, view: view),
                    view: view,
                    color: shadow.color.cgColor,
                    radius: shadow.radius,
                    offset: shadow.offset
                )
            } else {
                CoreViewSetShadow(
                    system: .caLayer,
                    view: layer,
                    color: shadow.color.cgColor,
                    radius: shadow.radius,
                    offset: shadow.offset
                )
            }
        } else {
            if viewSystem != .caLayer, let delegate = layer.delegate {
                let view = delegate as AnyObject
                CoreViewSetShadow(
                    system: CoreViewResolvedSystem(system: viewSystem, view: view),
                    view: view,
                    color: nil,
                    radius: 0,
                    offset: .zero
                )
            } else {
                CoreViewSetShadow(
                    system: .caLayer,
                    view: layer,
                    color: nil,
                    radius: 0,
                    offset: .zero
                )
            }
        }
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }
    
    func updateItemView(
        _ viewInfo: inout DisplayList.ViewUpdater.ViewInfo,
        index: DisplayList.Index,
        item: DisplayList.Item,
        state: UnsafePointer<DisplayList.ViewUpdater.Model.State>
    ) {
        _openSwiftUIUnimplementedFailure()
    }
    
    func updateItemViewAsync(
        layer: inout DisplayList.ViewUpdater.AsyncLayer,
        index: DisplayList.Index,
        oldItem: DisplayList.Item,
        oldState: UnsafePointer<DisplayList.ViewUpdater.Model.State>,
        newItem: DisplayList.Item,
        newState: UnsafePointer<DisplayList.ViewUpdater.Model.State>
    ) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }
    
    func updateState(
        _ viewInfo: inout DisplayList.ViewUpdater.ViewInfo,
        item: DisplayList.Item,
        size: CGSize,
        state: UnsafePointer<DisplayList.ViewUpdater.Model.State>
    ) {
        _openSwiftUIUnimplementedFailure()
    }
    
    func updateStateAsync(
        layer: inout DisplayList.ViewUpdater.AsyncLayer,
        oldItem: DisplayList.Item,
        oldSize: CGSize,
        oldState: UnsafePointer<DisplayList.ViewUpdater.Model.State>,
        newItem: DisplayList.Item,
        newSize: CGSize,
        newState: UnsafePointer<DisplayList.ViewUpdater.Model.State>
    ) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }
    
    func _makeItemView(
        item: DisplayList.Item,
        state: UnsafePointer<DisplayList.ViewUpdater.Model.State>
    ) -> DisplayList.ViewUpdater.ViewInfo {
        switch item.value {
        case let .content(content):
            switch content.value {
            case .backdrop:
                #if canImport(QuartzCore)
                let view = definition.makeLayerView(type: CABackdropLayer.self, kind: .backdrop)
                #else
                let view = definition.makeLayerView(type: CALayer.self, kind: .backdrop)
                _openSwiftUIPlatformUnimplementedWarning()
                #endif
                return DisplayList.ViewUpdater.ViewInfo(
                    view: view,
                    layer: viewLayer(view),
                    container: view,
                    state: .init(kind: .backdrop)
                )
            case .color:
                return DisplayList.ViewUpdater.ViewInfo(
                    platform: self,
                    kind: .color
                )
            case .chameleonColor:
                return DisplayList.ViewUpdater.ViewInfo(
                    platform: self,
                    kind: .chameleonColor
                )
            case .image:
                let view = definition.makeLayerView(type: ImageLayer.self, kind: .image)
                return DisplayList.ViewUpdater.ViewInfo(
                    view: view,
                    layer: viewLayer(view),
                    container: view,
                    state: .init(kind: .image)
                )
            case let .shape(path, paint, _):
                var visitor = ShapeLayerHelper.Visitor(
                    shapeType: ShapeType(path),
                    mayClip: !state.pointee.hasDODEffects,
                    requiredType: nil
                )
                paint.visit(&visitor)
                let view = definition.makeLayerView(type: visitor.requiredType!, kind: .shape)
                return DisplayList.ViewUpdater.ViewInfo(
                    view: view,
                    layer: viewLayer(view),
                    container: view,
                    state: .init(kind: .shape)
                )
            case .shadow:
                return DisplayList.ViewUpdater.ViewInfo(
                    platform: self,
                    kind: .shadow
                )
            case let .platformView(factory):
                let view = factory.makePlatformView() ?? missingPlatformView()
                definition.makePlatformView(view: view, kind: .platformView)
                return DisplayList.ViewUpdater.ViewInfo(
                    view: view,
                    layer: viewLayer(view),
                    container: view,
                    state: .init(kind: .platformView)
                )
            case let .platformLayer(factory):
                let layerType = factory.platformLayerType
                let view = definition.makeLayerView(type: layerType, kind: .platformLayer)
                return DisplayList.ViewUpdater.ViewInfo(
                    view: view,
                    layer: viewLayer(view),
                    container: view,
                    state: .init(kind: .platformLayer)
                )
            case .text:
                let view = definition.makeDrawingView(options: .init(base: .init())) as AnyObject
                return DisplayList.ViewUpdater.ViewInfo(
                    view: view,
                    layer: viewLayer(view),
                    container: view,
                    state: .init(kind: .drawing)
                )
            case let .flattened(_, _, options), let .drawing(_, _, options):
                let view = definition.makeDrawingView(options: .init(base: options)) as AnyObject
                return DisplayList.ViewUpdater.ViewInfo(
                    view: view,
                    layer: viewLayer(view),
                    container: view,
                    state: .init(kind: .drawing)
                )
            case .view, .placeholder:
                _openSwiftUIUnreachableCode()
            }
        case let .effect(effect, _):
            switch effect {
            case .geometryGroup:
                return DisplayList.ViewUpdater.ViewInfo(platform: self, kind: .geometry)
            case .compositingGroup:
                let info = DisplayList.ViewUpdater.ViewInfo(platform: self, kind: .compositing)
                #if canImport(QuartzCore)
                let layer = info.layer
                info.layer.allowsGroupOpacity = true
                info.layer.allowsGroupBlending = true
                #else
                _openSwiftUIPlatformUnimplementedWarning()
                #endif
                return info
            case let .platformGroup(factory):
                let view = factory.makePlatformGroup() ?? missingPlatformView()
                definition.makePlatformView(view: view, kind: .platformGroup)
                return DisplayList.ViewUpdater.ViewInfo(
                    view: view,
                    layer: viewLayer(view),
                    container: factory.platformGroupContainer(view),
                    state: .init(kind: .platformGroup)
                )
            case .mask:
                return DisplayList.ViewUpdater.ViewInfo(platform: self, kind: .mask)
            case let .transform(transform) where transform.projectionTransform != nil:
                var info = DisplayList.ViewUpdater.ViewInfo(platform: self, kind: .projection)
                info.state.isProjectionGeometryEnabled = true
                return info
            case .transform:
                _openSwiftUIUnreachableCode()
            case .platform:
                return DisplayList.ViewUpdater.ViewInfo(platform: self, kind: .platformEffect)
            default:
                _openSwiftUIUnreachableCode()
            }
        case .empty, .states:
            _openSwiftUIUnreachableCode()
        }
    }

    private func missingPlatformView() -> AnyObject {
        let drawable = definition.makeDrawingView(options: .init(base: .init()))
        let view = drawable as AnyObject
        setClipsToBounds(false, of: view, onLayer: false)
        var content = PlatformDrawableContent()
        content.storage = .graphicsCallback { context, size in
            context.renderMissingPlatformView(size: size)
        }
        _ = drawable.update(content: content, required: false)
        return view
    }

    private func updateShapeView(
        _ viewInfo: inout DisplayList.ViewUpdater.ViewInfo,
        state: inout DisplayList.ViewUpdater.Model.State,
        size: inout CGSize,
        path: Path,
        paint: AnyResolvedPaint,
        style: FillStyle,
        contentsChanged: Bool
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    private func updateShadowView(
        _ viewInfo: inout DisplayList.ViewUpdater.ViewInfo,
        path: Path,
        shadow: ResolvedShadowStyle,
        size: CGSize
    ) {
        #if canImport(QuartzCore)
        let layer = viewInfo.layer
        if path.boundingRect == CGRect(origin: .zero, size: size) {
            var helper = ShapeLayerShadowHelper(
                platform: self,
                layer: layer,
                path: path,
                offset: .zero,
                shadow: shadow,
                updateShape: true
            )
            helper.visitPaint(Color.Resolved.white)
        } else {
            layer.shadowPath = path.cgPath
            layer.shadowPathIsBounds = false
            setShadow(shadow, layer: layer)
        }
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }

    private func updateDrawingView(
        _ viewInfo: inout DisplayList.ViewUpdater.ViewInfo,
        options: RasterizationOptions,
        contentsScale: CGFloat,
        content: PlatformDrawableContent.Storage,
        sizeChanged: Bool
    ) {
        let oldView = viewInfo.view
        let drawable = updateDrawingView(
            &viewInfo.view,
            options: options,
            contentsScale: contentsScale
        )
        var drawableContent = PlatformDrawableContent()
        drawableContent.storage = content
        viewInfo.isInvalid = !drawable.update(
            content: drawableContent,
            required: sizeChanged
        )
        if viewInfo.view !== oldView {
            viewInfo.reset(platform: self)
        }
    }

    private func updateShapeViewAsync(
        layer: inout DisplayList.ViewUpdater.AsyncLayer,
        oldState: inout DisplayList.ViewUpdater.Model.State,
        oldSize: inout CGSize,
        oldPath: Path,
        oldPaint: AnyResolvedPaint,
        oldStyle: FillStyle,
        newState: inout DisplayList.ViewUpdater.Model.State,
        newSize: inout CGSize,
        newPath: Path,
        newPaint: AnyResolvedPaint,
        newStyle: FillStyle,
        contentsChanged: Bool
    ) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    private func updateDrawingViewAsync(
        _ asyncLayer: inout DisplayList.ViewUpdater.AsyncLayer,
        oldOptions: RasterizationOptions,
        newOptions: RasterizationOptions,
        content: PlatformDrawableContent.Storage,
        sizeChanged: Bool,
        newSize: CGSize,
        newState: UnsafePointer<DisplayList.ViewUpdater.Model.State>
    ) -> Bool {
        guard oldOptions == newOptions,
              let delegate = asyncLayer.layer.delegate,
              let drawable = delegate as? PlatformDrawable
        else {
            return false
        }
        let bounds: CGRect
        if asyncLayer.isClipRectEnabled, let clipRect = newState.pointee.clipRect() {
            bounds = clipRect.rect
        } else {
            bounds = CGRect(origin: .zero, size: newSize)
        }
        var drawableContent = PlatformDrawableContent()
        drawableContent.storage = content
        guard let update = drawable.makeAsyncUpdate(
            content: drawableContent,
            required: sizeChanged,
            layer: asyncLayer.layer,
            bounds: bounds
        ) else {
            return false
        }
        asyncLayer.cache.pointee.pendingAsyncUpdates.append(update)
        return true
    }

    private func updateClipShapes(
        _ viewInfo: inout DisplayList.ViewUpdater.ViewInfo,
        state: UnsafePointer<DisplayList.ViewUpdater.Model.State>
    ) {
        #if canImport(QuartzCore)
        if let clipRect = state.pointee.clipRect() {
            setClipsToBounds(true, of: viewInfo.view, onLayer: false)
            let layer = viewInfo.layer
            layer.cornerRadius = clipRect.clampedCornerRadius
            layer.cornerCurve = clipRect.style == .continuous ? .continuous : .circular
            viewInfo.state.isClipRectEnabled = true
            if viewInfo.state.isMaskLayerEnabled {
                layer.mask = nil
                viewInfo.state.isMaskLayerEnabled = false
            }

        } else {
            if viewInfo.state.isClipRectEnabled {
                viewInfo.state.isClipRectEnabled = false
                setClipsToBounds(false, of: viewInfo.view, onLayer: false)
                let layer = viewInfo.layer
                var bounds = layer.bounds
                bounds.origin = .zero
                layer.bounds = bounds
                layer.cornerRadius = 0
                layer.cornerCurve = .circular
            }
            let clips = state.pointee.clips
            guard !clips.isEmpty else {
                if viewInfo.state.isMaskLayerEnabled {
                    let layer = viewInfo.layer
                    layer.mask = nil
                    viewInfo.state.isMaskLayerEnabled = false
                }
                return
            }
            let layer = viewInfo.layer
            let maskLayer: MaskLayer
            if let mask = layer.mask as? MaskLayer {
                maskLayer = mask
            } else {
                maskLayer = MaskLayer()
                maskLayer.anchorPoint = .zero
                maskLayer.setNoAnimationDelegate()
                layer.mask = maskLayer
            }
            viewInfo.state.isMaskLayerEnabled = true
            let transform = state.pointee.transform.inverted()
            if maskLayer.clips != clips || maskLayer.clipTransform != transform {
                maskLayer.setClips(clips, transform: transform)
            }
        }
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }

    private func updateGeometry(
        _ viewInfo: inout DisplayList.ViewUpdater.ViewInfo,
        item: DisplayList.Item,
        size: CGSize,
        state: UnsafePointer<DisplayList.ViewUpdater.Model.State>,
        clipRectChanged: Bool
    ) -> Bool {
        #if canImport(QuartzCore)
        let modelState = state.pointee
        let sizeChanged = viewInfo.state.size != size
        let transformSeed = DisplayList.Seed(modelState.versions.transform)
        let transformChanged = viewInfo.seeds.transform != transformSeed
        viewInfo.seeds.transform = transformSeed
        guard sizeChanged || transformChanged || clipRectChanged else {
            return false
        }
        // TBA
        let hadBoundsOrigin = viewInfo.state.isBoundsOriginEnabled
        let hadAffineTransform = viewInfo.state.isAffineTransformEnabled
        let usesProjection = viewInfo.state.isProjectionGeometryEnabled
        let usesClipRect = viewInfo.state.isClipRectEnabled

        var clipRectPresent = false
        var bounds = CGRect(origin: .zero, size: size)
        var position = CGPoint(x: modelState.transform.tx, y: modelState.transform.ty)
        if usesClipRect, let clipRect = modelState.clipRect() {
            clipRectPresent = true
            bounds = clipRect.rect
            position.x += bounds.origin.x
            position.y += bounds.origin.y
        }

        let shouldComparePosition = transformChanged || (clipRectPresent && clipRectChanged)
        let positionChanged = shouldComparePosition && viewInfo.state.position != position
        if positionChanged {
            viewInfo.state.position = position
        }

        let boundsSizeChanged = viewInfo.state.size != bounds.size
        if boundsSizeChanged {
            viewInfo.state.size = bounds.size
        }

        let hasBoundsOrigin = bounds.origin != .zero
        let boundsOriginChanged = hadBoundsOrigin || hasBoundsOrigin
        let boundsChanged = boundsOriginChanged || boundsSizeChanged

        if boundsOriginChanged {
            viewInfo.state.isBoundsOriginEnabled = hasBoundsOrigin
        }

        if usesProjection {
            if boundsChanged {
                CoreViewSetSize(system: viewSystem, view: viewInfo.view, size: bounds.size)
            }
            viewLayer(viewInfo.view).contentsScale = modelState.globals.pointee.environment.contentsScale
            if boundsChanged, viewInfo.state.kind == .mask {
                setMaskGeometry(of: viewInfo.view, bounds: bounds)
            }
            return boundsChanged
        }

        var affineTransform = modelState.transform
        affineTransform.tx = 0
        affineTransform.ty = 0
        let hasAffineTransform = affineTransform != .identity
        if transformChanged && (hadAffineTransform || hasAffineTransform) {
            CoreViewSetTransform(
                system: viewSystem,
                view: viewInfo.view,
                transform: affineTransform
            )
            if hasAffineTransform {
                viewInfo.state.isAffineTransformEnabled = true
            } else {
                viewInfo.state.isAffineTransformEnabled = false
            }
        }

        let useViewAPIs: Bool
        switch viewInfo.state.kind {
        case .platformView, .platformGroup, .platformLayer:
            useViewAPIs = true
        default:
            useViewAPIs = false
        }
        let sanitizedPosition = CGPoint(
            x: position.x.mappingNaN(to: 0),
            y: position.y.mappingNaN(to: 0)
        )
        let sanitizedBounds = CGRect(
            x: bounds.origin.x.mappingNaN(to: 0),
            y: bounds.origin.y.mappingNaN(to: 0),
            width: bounds.size.width.mappingNaN(to: 0),
            height: bounds.size.height.mappingNaN(to: 0)
        )
        setGeometry(
            of: viewInfo.view,
            useViewAPIs: useViewAPIs,
            positionChanged: positionChanged,
            boundsOriginChanged: boundsOriginChanged,
            boundsSizeChanged: boundsSizeChanged,
            position: sanitizedPosition,
            bounds: sanitizedBounds
        )

        if boundsChanged, viewInfo.state.kind == .mask {
            setMaskGeometry(of: viewInfo.view, bounds: bounds)
        }
        return boundsChanged
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return false
        #endif
    }

    private func updateShadow(
        _ viewInfo: inout DisplayList.ViewUpdater.ViewInfo,
        state: UnsafePointer<DisplayList.ViewUpdater.Model.State>,
        item: DisplayList.Item
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    private func updateProperties(
        _ viewInfo: inout DisplayList.ViewUpdater.ViewInfo,
        state: UnsafePointer<DisplayList.ViewUpdater.Model.State>
    ) {
        let properties = state.pointee.properties
        definition.setIgnoresEvents(
            properties.contains(.ignoresEvents),
            of: viewInfo.view
        )
        #if canImport(QuartzCore)
        // TODO: Add CALayerDisableUpdateMask enum in the future
        viewLayer(viewInfo.view).disableUpdateMask = properties.contains(.screencaptureProhibited) ? 0x12 : 0
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }

    private func updateClipShapesAsync(
        asyncLayer: inout DisplayList.ViewUpdater.AsyncLayer,
        oldState: UnsafePointer<DisplayList.ViewUpdater.Model.State>,
        newState: UnsafePointer<DisplayList.ViewUpdater.Model.State>
    ) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    private func updateGeometryAsync(
        asyncLayer: inout DisplayList.ViewUpdater.AsyncLayer,
        oldItem: DisplayList.Item,
        oldSize: CGSize,
        oldState: UnsafePointer<DisplayList.ViewUpdater.Model.State>,
        newItem: DisplayList.Item,
        newSize: CGSize,
        newState: UnsafePointer<DisplayList.ViewUpdater.Model.State>
    ) -> Bool? {
        _openSwiftUIUnimplementedFailure()
    }

    private func updateShadowAsync(
        asyncLayer: inout DisplayList.ViewUpdater.AsyncLayer,
        oldState: UnsafePointer<DisplayList.ViewUpdater.Model.State>,
        oldItem: DisplayList.Item,
        newState: UnsafePointer<DisplayList.ViewUpdater.Model.State>,
        newItem: DisplayList.Item,
        boundsChanged: Bool
    ) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    func updateDrawingView(
        _ drawingView: inout AnyObject,
        options: RasterizationOptions,
        contentsScale: CGFloat
    ) -> any PlatformDrawable {
        var drawable = (drawingView as? PlatformDrawable) ?? definition.makeDrawingView(options: .init(base: options))
        let oldOption = drawable.options.base
        if options != oldOption {
            if oldOption.flags.symmetricDifference(options.flags).contains(.isAccelerated) {
                drawable = definition.makeDrawingView(options: .init(base: options))
            } else {
                drawable.options.base = options
            }
        }
        drawable.setContentsScale(contentsScale)
        drawingView = drawable
        return drawable
    }

    // TBA
    @inline(__always)
    private func updateContentView(
        _ viewInfo: inout DisplayList.ViewUpdater.ViewInfo,
        content: DisplayList.Content,
        item: DisplayList.Item,
        state: UnsafePointer<DisplayList.ViewUpdater.Model.State>
    ) {
        switch content.value {
        case let .color(resolved):
            let cgColor = resolved.cgColor
            viewLayer(viewInfo.view).backgroundColor = cgColor
        case .backdrop, .chameleonColor, .image, .shadow, .view, .placeholder:
            break
        case let .shape(path, _, _):
            definition.setPath(path, shapeView: viewInfo.view)
        case let .platformView(factory):
            var view = viewInfo.view
            factory.updatePlatformView(&view)
            updateViewReference(&viewInfo, view: view, kind: .platformView)
        case let .platformLayer(factory):
            #if canImport(QuartzCore)
            if let layer = viewInfo.view as? CALayer {
                factory.updatePlatformLayer(layer)
            }
            #endif
        case .text, .flattened, .drawing:
            updateDrawingContent(&viewInfo, content: content, item: item, state: state)
        }
    }

    // TBA
    @inline(__always)
    private func updateEffectView(
        _ viewInfo: inout DisplayList.ViewUpdater.ViewInfo,
        effect: DisplayList.Effect,
        item: DisplayList.Item,
        state: UnsafePointer<DisplayList.ViewUpdater.Model.State>
    ) {
        switch effect {
        case let .transform(transform):
            if case let .projection(projectionTransform) = transform {
                definition.setProjectionTransform(
                    projectionTransform,
                    projectionView: viewInfo.view
                )
            }
        case let .platformGroup(factory):
            var view = viewInfo.view
            factory.updatePlatformGroup(&view)
            updateViewReference(&viewInfo, view: view, kind: .platformGroup)
            viewInfo.container = factory.platformGroupContainer(viewInfo.view)
        case .identity, .geometryGroup, .compositingGroup, .backdropGroup, .archive,
             .properties, .opacity, .blendMode, .clip, .mask, .filter, .animation,
             .contentTransition, .view, .accessibility, .platform, .state,
             .interpolatorRoot, .interpolatorLayer, .interpolatorAnimation:
            break
        }
    }
    
    // TBA
    @inline(__always)
    private func updateDrawingContent(
        _ viewInfo: inout DisplayList.ViewUpdater.ViewInfo,
        content: DisplayList.Content,
        item: DisplayList.Item,
        state: UnsafePointer<DisplayList.ViewUpdater.Model.State>
    ) {
        let contentsScale = state.pointee.globals.pointee.environment.contentsScale
        let options = drawingOptions(for: content, state: state)
        var view = viewInfo.view
        let drawable = updateDrawingView(
            &view,
            options: options,
            contentsScale: contentsScale
        )
        updateViewReference(&viewInfo, view: view, kind: .drawing)
        var drawableContent = PlatformDrawableContent()
        switch content.value {
        case let .flattened(list, offset, _):
            drawableContent.storage = .displayList(
                list,
                offset,
                state.pointee.globals.pointee.time
            )
        case let .drawing(contents, offset, _):
            drawableContent.storage = .rbDisplayList(contents, offset)
        case .text:
            drawableContent.storage = .empty
        default:
            return
        }
        _ = drawable.update(
            content: drawableContent,
            required: item.features.contains(.required)
        )
    }

    // TBA
    @inline(__always)
    private func updateViewReference(
        _ viewInfo: inout DisplayList.ViewUpdater.ViewInfo,
        view: AnyObject,
        kind: PlatformViewDefinition.ViewKind
    ) {
        guard viewInfo.view !== view else {
            return
        }
        viewInfo.view = view
        viewInfo.container = view
        viewInfo.reset(platform: self)
    }

    func forEachChild(
        of viewInfo: DisplayList.ViewUpdater.ViewInfo,
        do body: (AnyObject) -> Void
    ) {
        #if canImport(Darwin)
        let kind = viewInfo.state.kind
        if kind.isContainer {
            for subview in subviews(viewInfo.container) {
                body(subview)
            }
        }
        if kind == .mask,
           let maskView = maskView(viewInfo.view) {
            for subview in subviews(maskView) {
                body(subview as AnyObject)
            }
        }
        #endif
    }
}

// MARK: - DisplayList.GraphicsRenderer + Platform [WIP]

extension DisplayList.GraphicsRenderer {
    package func drawPlatformLayer(
        _ layer: CALayer,
        in ctx: GraphicsContext,
        size: CGSize,
        update: Bool
    ) {
        #if canImport(Darwin)
        if update {
            layer.bounds = CGRect(origin: .zero, size: size)
            layer.layoutIfNeeded()
        }
        try? ctx.drawLayer(flags: []) { _ in
            // TODO: Blocked by GraphicsContext
            _openSwiftUIUnimplementedFailure()
        }
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }
}
