//
//  DisplayListViewPlatform.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Blocked by PlatformDrawable and GraphicsContext
//  ID: 8BBC66CBE42B8A65F8A2F3799C81A349 (SwiftUICore)

import OpenSwiftUI_SPI
#if canImport(QuartzCore)
public import QuartzCore
#else
import Foundation
#endif

@_spi(DisplayList_ViewSystem)
@available(OpenSwiftUI_v6_0, *)
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
  
    open class var system: PlatformViewDefinition.System { .init(base: .caLayer) }
    #if os(visionOS) // TODO: VWT alignment issue when running for Designed for iPad
    open class func makeView(kind: PlatformViewDefinition.ViewKind, item: Any) -> AnyObject { _openSwiftUIBaseClassAbstractMethod() }
    #endif
    open class func makeView(kind: PlatformViewDefinition.ViewKind) -> AnyObject { _openSwiftUIBaseClassAbstractMethod() }
    #if canImport(Darwin)
    open class func makeLayerView(type: CALayer.Type, kind: PlatformViewDefinition.ViewKind) -> AnyObject { _openSwiftUIBaseClassAbstractMethod() }
    #endif
    open class func makePlatformView(view: AnyObject, kind: PlatformViewDefinition.ViewKind) { _openSwiftUIBaseClassAbstractMethod() }
    open class func makeDrawingView(options: PlatformDrawableOptions) -> any PlatformDrawable { _openSwiftUIBaseClassAbstractMethod() }
    open class func setPath(_ path: Path, shapeView: AnyObject) { _openSwiftUIBaseClassAbstractMethod() }
    open class func setProjectionTransform(_ transform: ProjectionTransform, projectionView: AnyObject) { _openSwiftUIBaseClassAbstractMethod() }
    open class func getRBLayer(drawingView: AnyObject) -> AnyObject? { _openSwiftUIBaseClassAbstractMethod() }
    open class func setIgnoresEvents(_ state: Bool, of view: AnyObject) { _openSwiftUIBaseClassAbstractMethod() }
    open class func setAllowsWindowActivationEvents(_ value: Bool?, for view: AnyObject) { _openSwiftUIBaseClassAbstractMethod() }
    open class func setHitTestsAsOpaque(_ value: Bool, for view: AnyObject) { _openSwiftUIBaseClassAbstractMethod() }
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

    @inline(__always)
    var viewSystem: ViewSystem {
        return unsafeBitCast(UInt8(rawValue & 3), to: ViewSystem.self)
    }

    #if canImport(QuartzCore)
    package func viewLayer(_ view: AnyObject) -> CALayer {
        CoreViewLayer(system: viewSystem, view: view)
    }
    #endif
}

extension DisplayList.GraphicsRenderer {
    #if canImport(Darwin)
    final package func drawPlatformLayer(_ layer: CALayer, in ctx: GraphicsContext, size: CGSize, update: Bool) {
        if update {
            layer.bounds = CGRect(origin: .zero, size: size)
            layer.layoutIfNeeded()
        }
        // TODO: Blocked by GraphicsContext
        _openSwiftUIUnimplementedFailure()
        // ctx.drawLayer
    }
    #endif
}
