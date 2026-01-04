//
//  AppKitDisplayList.swift
//  OpenSwiftUI
//
//  Audited for 6.0.87
//  Status: WIP
//  ID: 33EEAA67E0460DA84AE814EA027152BA (SwiftUI)

#if os(macOS)
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore
import AppKit
import OpenSwiftUISymbolDualTestsSupport
import COpenSwiftUI
import CoreAnimation_Private
import OpenSwiftUI_SPI

// MARK: - NSViewPlatformViewDefinition [TODO]

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
            view = _NSGraphicsView()
            view.mask = _NSInheritedView()
            initView(view.mask!, kind: kind)
        default:
            view = kind.isContainer ? _NSInheritedView() : _NSGraphicsView()
        }
        initView(view, kind: kind)
        return view
    }

    private static func initView(_ view: NSView, kind: PlatformViewDefinition.ViewKind) {
        view.wantsLayer = true
        
        if kind != .platformView && kind != .platformGroup {
            view.setFlipped(true)
            view.autoresizesSubviews = false
            // TODO - UnifiedHitTestingFeature.isEnabled
            // setIgnoreHitTest: true
        }
        
        switch kind {
        case .color, .image, .shape:
            view.layer?.edgeAntialiasingMask = [.layerTopEdge, .layerBottomEdge, .layerLeftEdge, .layerRightEdge]
            view.layer?.allowsEdgeAntialiasing = true
            break
        case .geometry, .projection, .mask:
            view.layer?.allowsGroupOpacity = false
            view.layer?.allowsGroupBlending = false
        default:
            break
        }
    }
    
    override static func makeLayerView(type: CALayer.Type, kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        _openSwiftUIUnimplementedFailure()
    }

    override class func makePlatformView(view: AnyObject, kind: PlatformViewDefinition.ViewKind) {
        Self.initView(view as! NSView, kind: kind)
    }

    override class func setProjectionTransform(_ transform: ProjectionTransform, projectionView: AnyObject) {
        guard let view = projectionView as? _NSProjectionView else {
            return
        }
        view.projectionTransform = transform
        view.layer?.transform = .init(transform)
    }

    override class func setAllowsWindowActivationEvents(_ value: Bool?, for view: AnyObject) {
        _openSwiftUIUnimplementedWarning()
    }

    override class func setHitTestsAsOpaque(_ value: Bool, for view: AnyObject) {
        _openSwiftUIUnimplementedWarning()
    }
}

// MARK: - _NSGraphicsView

typealias PlatformGraphicsView = _NSGraphicsView

class _NSGraphicsView: NSView {
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

class _NSInheritedView: _NSGraphicsView {
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
#endif
