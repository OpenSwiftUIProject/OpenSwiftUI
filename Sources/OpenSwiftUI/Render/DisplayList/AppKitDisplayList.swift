//
//  AppKitDisplayList.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 33EEAA67E0460DA84AE814EA027152BA (SwiftUI)

#if os(macOS)
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore
import AppKit
import OpenSwiftUISymbolDualTestsSupport
import COpenSwiftUI
import QuartzCore_Private
import OpenRenderBoxShims
import OpenSwiftUI_SPI

// MARK: - NSViewPlatformViewDefinition

final class NSViewPlatformViewDefinition: PlatformViewDefinition, @unchecked Sendable {
    override final class var system: PlatformViewDefinition.System { .nsView }

    override static func makeView(kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        let view: NSView
        switch kind {
        case .chameleonColor:
            return makeLayerView(type: CAChameleonLayer.self, kind: kind)
        case .projection:
            view = _NSProjectionView()
        case .mask:
            view = _NSInheritedView()
            let maskView = _NSInheritedView()
            view.maskView = maskView
            initView(maskView, kind: .inherited)
        default:
            view = kind.isContainer ? _NSInheritedView() : _NSGraphicsView()
        }
        initView(view, kind: kind)
        return view
    }
    
    override static func makeLayerView(type: CALayer.Type, kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        let cls: NSView.Type
        switch kind {
        case .shape:
            cls = _NSShapeHitTestingView.self
        case .platformLayer:
            cls = _NSPlatformLayerView.self
        default:
            cls = kind.isContainer ? _NSInheritedView.self : _NSGraphicsView.self
        }
        let view = cls.init()
        let layer = type.init()
        _SetLayerViewDelegate(layer, view)
        view.layer = layer
        initView(view, kind: kind)
        return view
    }

    override class func makePlatformView(view: AnyObject, kind: PlatformViewDefinition.ViewKind) {
        Self.initView(view as! NSView, kind: kind)
    }

    override class func makeDrawingView(options: PlatformDrawableOptions) -> any PlatformDrawable {
        let view: NSView & PlatformDrawable
        if options.isAccelerated && ORBDevice.isSupported() {
            view = RBDrawingView(options: options)
        } else {
            view = CGDrawingView(options: options)
        }
        view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        view.layerContentsPlacement = .topLeft
        initView(view, kind: .drawing)
        return view
    }

    override static func setPath(_ path: Path, shapeView: AnyObject) {
        guard let view = shapeView as? _NSShapeHitTestingView else { return }
        view.path = path
    }

    override class func setProjectionTransform(_ transform: ProjectionTransform, projectionView: AnyObject) {
        guard let view = projectionView as? _NSProjectionView else {
            return
        }
        view.projectionTransform = transform
        view.layer?.transform = CATransform3D(transform)
    }

    override class func getRBLayer(drawingView: AnyObject) -> AnyObject? {
        guard let rbView = drawingView as? RBDrawingView else { return nil }
        return rbView.layer
    }

    override class func setIgnoresEvents(_ state: Bool, of view: AnyObject) {
        guard !ResponderBasedHitTesting.enabled else { return }
        if Semantics.UnifiedHitTesting.isEnabled {
            if let customizing = view as? RecursiveIgnoreHitTestCustomizing {
                customizing.recursiveIgnoreHitTest = state
            }
        } else {
            let view = unsafeBitCast(view, to: NSView.self)
            view.ignoreHitTest = state
        }
    }

    override class func setAllowsWindowActivationEvents(_ value: Bool?, for view: AnyObject) {
        guard !ResponderBasedHitTesting.enabled else { return }
        if let customizing = view as? AcceptsFirstMouseCustomizing {
            customizing.customAcceptsFirstMouse = value
        }
    }

    override class func setHitTestsAsOpaque(_ value: Bool, for view: AnyObject) {
        guard !ResponderBasedHitTesting.enabled else { return }
        if let customizing = view as? HitTestsAsOpaqueCustomizing {
            customizing.hitTestsAsOpaque = value
        }
    }

    private static func initView(_ view: NSView, kind: PlatformViewDefinition.ViewKind) {
        view.wantsLayer = true
        if kind != .platformView && kind != .platformGroup {
            view.setFlipped(true)
            view.autoresizesSubviews = false
            view.clipsToBounds = false
            if !Semantics.UnifiedHitTesting.isEnabled {
                view.ignoreHitTest = true
            }
        }
        switch kind {
        case .color, .image, .shape:
            let layer = view.layer!
            layer.edgeAntialiasingMask = [.layerTopEdge, .layerBottomEdge, .layerLeftEdge, .layerRightEdge]
            layer.allowsEdgeAntialiasing = true
        case .inherited, .geometry, .projection, .mask:
            let layer = view.layer!
            layer.allowsGroupOpacity = false
            layer.allowsGroupBlending = false
        default:
            break
        }
    }
}

// MARK: - _NSGraphicsView

typealias PlatformGraphicsView = _NSGraphicsView

class _NSGraphicsView: NSView, RecursiveIgnoreHitTestCustomizing, AcceptsFirstMouseCustomizing {
    var recursiveIgnoreHitTest: Bool = false

    var customAcceptsFirstMouse: Bool?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - _NSInheritedView

typealias PlatformInheritedView = _NSInheritedView

class _NSInheritedView: _NSGraphicsView, HitTestsAsOpaqueCustomizing {
    var hitTestsAsOpaque: Bool = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - _NSProjectionView [6.5.4]

@objc
private class _NSProjectionView: _NSInheritedView {
    var projectionTransform: ProjectionTransform

    override init(frame frameRect: NSRect) {
        projectionTransform = .init()
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        projectionTransform = .init()
        super.init(coder: coder)
    }

    override var wantsUpdateLayer: Bool { true }

    override func _updateLayerGeometryFromView() {
        super._updateLayerGeometryFromView()
        layer?.transform = .init(projectionTransform)
    }
}

// MARK: - _NSShapeHitTestingView [WIP]

@objc
private class _NSShapeHitTestingView: _NSGraphicsView {
    var path: Path

    override init(frame frameRect: NSRect) {
        path = .init()
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        path = .init()
        super.init(coder: coder)
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // path.contains(, eoFill: false)
        _openSwiftUIUnimplementedWarning()
        return nil
    }
}

// MARK: - _NSPlatformLayerView

@objc
private class _NSPlatformLayerView: _NSGraphicsView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func _updateLayerShadowFromView() {
        _openSwiftUIEmptyStub()
    }

    override func _updateLayerShadowColorFromView() {
        _openSwiftUIEmptyStub()
    }
}

#endif
