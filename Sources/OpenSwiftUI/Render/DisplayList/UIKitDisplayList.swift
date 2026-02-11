//
//  UIKitDisplayList.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A34643117F00277B93DEBAB70EC06971 (SwiftUI)

#if os(iOS) || os(visionOS)
import COpenSwiftUI
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore
import UIKit
import OpenSwiftUISymbolDualTestsSupport
import QuartzCore_Private
import OpenRenderBoxShims
import OpenSwiftUI_SPI

// MARK: - UIViewPlatformViewDefinition

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
        let cls: UIView.Type
        switch kind {
        case .shape:
            cls = _UIShapeHitTestingView.self
        default:
            cls = kind.isContainer ? _UIInheritedView.self : _UIGraphicsView.self
        }
        let layer = type.init()
        let view = _UIKitCreateCustomView(cls, layer)
        initView(view, kind: kind)
        return view
    }

    override class func makePlatformView(view: AnyObject, kind: PlatformViewDefinition.ViewKind) {
        Self.initView(view as! UIView, kind: kind)
    }

    override class func makeDrawingView(options: PlatformDrawableOptions) -> any PlatformDrawable {
        let view: UIView & PlatformDrawable
        if options.isAccelerated && ORBDevice.isSupported() {
            view = RBDrawingView(options: options)
        } else {
            view = CGDrawingView(options: options)
        }
        view.contentMode = .topLeft
        initView(view, kind: .drawing)
        return view
    }

    override static func setPath(_ path: Path, shapeView: AnyObject) {
        let view = unsafeBitCast(shapeView, to: _UIShapeHitTestingView.self)
        view.path = path
    }

    override class func setProjectionTransform(_ transform: ProjectionTransform, projectionView: AnyObject) {
        let layer = CoreViewLayer(system: .uiView, view: projectionView)
        layer.transform = CATransform3D(transform)
    }

    override class func getRBLayer(drawingView: AnyObject) -> AnyObject? {
        guard let rbView = drawingView as? RBDrawingView else { return nil }
        return rbView.layer
    }

    override class func setIgnoresEvents(_ state: Bool, of view: AnyObject) {
        let view = unsafeBitCast(view, to: UIView.self)
        view.isUserInteractionEnabled = !state
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

// MARK: - _UIGraphicsView

typealias PlatformGraphicsView = _UIGraphicsView

class _UIGraphicsView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func _shouldAnimateProperty(withKey key: String) -> Bool {
        if layer.hasBeenCommitted {
            super._shouldAnimateProperty(withKey: key)
        } else {
            false
        }
    }
}

// MARK: - _UIInheritedView

typealias PlatformInheritedView = _UIInheritedView

final class _UIInheritedView: _UIGraphicsView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !UIViewIgnoresTouchEvents(self) else {
            return nil
        }
        for subview in subviews.reversed() {
            let convertedPoint = convert(point, to: subview)
            let result = subview.hitTest(convertedPoint, with: event)
            if let result {
                return result
            }
        }
        return nil
    }
}

// MARK: - _UIShapeHitTestingView

private final class _UIShapeHitTestingView: _UIGraphicsView {
    var path: Path = .init()

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard super.hitTest(point, with: event) != nil, path.contains(point, eoFill: false) else {
            return nil
        }
        return self
    }
}

#endif
