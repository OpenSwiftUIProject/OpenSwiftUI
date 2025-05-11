//
//  PlatformViewDefinition.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by PlatformDrawable and GraphicsContext

import OpenSwiftUI_SPI
#if canImport(Darwin)
public import QuartzCore
#else
import Foundation
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
  
    open class var system: PlatformViewDefinition.System { .init(base: .swiftUIView) }

    #if _OPENSWIFTUI_SWIFTUI_RENDER
    open class func makeView(kind: UnsafePointer<PlatformViewDefinition.ViewKind>) -> AnyObject { preconditionFailure("") }
    #if canImport(Darwin)
    open class func makeLayerView(type: CALayer.Type, kind: UnsafePointer<PlatformViewDefinition.ViewKind>) -> AnyObject { preconditionFailure("") }
    #endif
    open class func makePlatformView(view: AnyObject, kind: UnsafePointer<PlatformViewDefinition.ViewKind>) { preconditionFailure("") }
    #else
    open class func makeView(kind: PlatformViewDefinition.ViewKind) -> AnyObject { preconditionFailure("") }
    #if canImport(Darwin)
    open class func makeLayerView(type: CALayer.Type, kind: PlatformViewDefinition.ViewKind) -> AnyObject { preconditionFailure("") }
    #endif
    open class func makePlatformView(view: AnyObject, kind: PlatformViewDefinition.ViewKind) { preconditionFailure("") }
    #endif
    open class func makeDrawingView(options: PlatformDrawableOptions) -> any PlatformDrawable { preconditionFailure("") }
    open class func setPath(_ path: Path, shapeView: AnyObject) { preconditionFailure("") }
    open class func setProjectionTransform(_ transform: ProjectionTransform, projectionView: AnyObject) { preconditionFailure("") }
    open class func getRBLayer(drawingView: AnyObject) -> AnyObject? { preconditionFailure("") }
    open class func setIgnoresEvents(_ state: Bool, of view: AnyObject) { preconditionFailure("") }
    open class func setAllowsWindowActivationEvents(_ value: Bool?, for view: AnyObject) { preconditionFailure("") }
    open class func setHitTestsAsOpaque(_ value: Bool, for view: AnyObject) { preconditionFailure("") }
}

extension DisplayList.ViewUpdater {
    package struct Platform {
        let rawValue: UInt

        struct State {
            var position: CGPoint
            var size: CGSize
            let kind: PlatformViewDefinition.ViewKind
            var flags: ViewFlags
            var platformState: Platform.PlatformState
        }

        struct ViewFlags {
            let rawValue: UInt8
        }
    }
}

extension DisplayList.ViewUpdater.Platform {
    package init(definition: PlatformViewDefinition.Type) {
        self.init(rawValue: UInt(bitPattern: ObjectIdentifier(definition)) | UInt(definition.system.base.rawValue))
    }
    
    @inline(__always)
    var definition: PlatformViewDefinition.Type {
        return unsafeBitCast(rawValue & ~3, to: PlatformViewDefinition.Type.self)
    }
}

extension DisplayList.GraphicsRenderer {
    #if canImport(Darwin)
    final package func drawPlatformLayer(_ layer: CALayer, in ctx: GraphicsContext, size: CGSize, update: Bool) {
        if update {
            layer.bounds = CGRect(origin: .zero, size: size)
            layer.layoutIfNeeded()
        }
        preconditionFailure("Blocked by GraphicsContext")
        // ctx.drawLayer
    }
    #endif
}
