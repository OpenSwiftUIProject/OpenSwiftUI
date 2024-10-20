//
//  PlatformViewDefinition.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Blocked by PlatformDrawable and GraphicsContext

internal import COpenSwiftUICore
#if canImport(Darwin)
import QuartzCore
#endif

@_spi(DisplayList_ViewSystem)
open class PlatformViewDefinition: @unchecked Sendable {
    public struct System: Hashable, Sendable {
        public static let uiView = PlatformViewDefinition.System(base: .uiView)
        public static let nsView = PlatformViewDefinition.System(base: .nsView)
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
  
    open class var system: PlatformViewDefinition.System { .init(base: ._2) }
    open class func makeView(kind: PlatformViewDefinition.ViewKind) -> AnyObject { fatalError() }
    #if canImport(Darwin)
    open class func makeLayerView(type: CALayer.Type, kind: PlatformViewDefinition.ViewKind) -> AnyObject { fatalError() }
    #endif
    open class func makePlatformView(view: AnyObject, kind: PlatformViewDefinition.ViewKind) { fatalError() }
    // open class func makeDrawingView(options: PlatformDrawableOptions) -> any PlatformDrawable { fatalError() }
    open class func setPath(_ path: Path, shapeView: AnyObject) { fatalError() }
    open class func setProjectionTransform(_ transform: ProjectionTransform, projectionView: AnyObject) { fatalError() }
    open class func getRBLayer(drawingView: AnyObject) -> AnyObject? { fatalError() }
    open class func setIgnoresEvents(_ state: Bool, of view: AnyObject) { fatalError() }
    open class func setAllowsWindowActivationEvents(_ value: Bool?, for view: AnyObject) { fatalError() }
    open class func setHitTestsAsOpaque(_ value: Bool, for view: AnyObject) { fatalError() }
}

extension DisplayList.ViewUpdater {
    package struct Platform {
        let rawValue: UInt
    }
}

extension DisplayList.ViewUpdater.Platform {
    package init(definition: PlatformViewDefinition.Type) {
        self.init(rawValue: UInt(bitPattern: ObjectIdentifier(definition)) | UInt(definition.system.base.rawValue))
    }
    
    @inline(__always)
    var definition: PlatformViewDefinition.Type {
        let rawValue = self.rawValue & 0xFFFF_FFFF_FFFF_FFFC
        return unsafeBitCast(rawValue, to: PlatformViewDefinition.Type.self)
    }
}

extension DisplayList.GraphicsRenderer {
    #if canImport(Darwin)
    final package func drawPlatformLayer(_ layer: CALayer, in ctx: GraphicsContext, size: CGSize, update: Bool) {
        if update {
            layer.bounds = CGRect(origin: .zero, size: size)
            layer.layoutIfNeeded()
        }
        fatalError("Blocked by GraphicsContext")
        // ctx.drawLayer
    }
    #endif
}
