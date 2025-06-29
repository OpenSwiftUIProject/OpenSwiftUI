//
//  NSViewPlatformViewDefinition.swift
//  OpenSwiftUI
//
//  Audited for macOS 15.0
//  Status: WIP

#if os(macOS)
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore
import AppKit
import OpenSwiftUISymbolDualTestsSupport
import COpenSwiftUI

// TODO
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
        openSwiftUIUnimplementedFailure()
    }
}
#endif
