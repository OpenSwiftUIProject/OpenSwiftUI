//
//  UIViewPlatformViewDefinition.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: A34643117F00277B93DEBAB70EC06971 (SwiftUI?)

#if os(iOS)
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore
import UIKit
import OpenSwiftUISymbolDualTestsSupport

// TODO
final class UIViewPlatformViewDefinition: PlatformViewDefinition, @unchecked Sendable {
    override final class var system: PlatformViewDefinition.System { .uiView }

    override static func makeView(kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        let view: UIView
        switch kind {
        case .mask:
            view = _UIGraphicsView()
            view.mask = _UIInheritedView()
            initView(view.mask!, kind: kind)
        default:
            view = kind.isContainer ? _UIInheritedView() : _UIGraphicsView()
        }
        initView(view, kind: kind)
        return view
    }

    override static func makeLayerView(type: CALayer.Type, kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        preconditionFailure("TODO")
    }

    private static func initView(_ view: UIView, kind: PlatformViewDefinition.ViewKind) {
        if kind != .platformView && kind != .platformGroup {
            view.autoresizesSubviews = false
            if !kind.isContainer {
                view._setFocusInteractionEnabled(false)
            }
        }
        view.layer.anchorPoint = .zero
        switch kind {
        case .color, .image, .shape:
            view.layer.allowsEdgeAntialiasing = true
            break
        case .geometry, .projection, .affine3D, .mask, .platformEffect:
            let layer = view.layer
            layer.allowsGroupOpacity = false
            layer.allowsGroupBlending = false
            break
        default:
            break
        }
    }
}
#endif
