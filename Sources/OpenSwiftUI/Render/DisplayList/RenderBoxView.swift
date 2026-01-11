//
//  RenderBoxView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 0CB954C9DC99A8A907C58D7882F9389E (SwiftUI)

#if canImport(Darwin)
import Foundation
import QuartzCore
import QuartzCore_Private
import OpenRenderBoxShims

// MARK: - RenderBoxView

@objc
class RenderBoxView: PlatformGraphicsView {
    var rendersFirstFrameAsynchronously: Bool

    override class var layerClass: AnyClass {
        RenderBoxLayer.self
    }

    override init(frame: CGRect) {
        rendersFirstFrameAsynchronously = false
        super.init(frame: frame)
        let layer = layer
        layer.delegate = self
        layer.isOpaque = isOpaque
    }
    
    required init?(coder: NSCoder) {
        rendersFirstFrameAsynchronously = false
        super.init(coder: coder)
        let layer = layer
        layer.delegate = self
        layer.isOpaque = isOpaque
    }

    deinit {
        (layer as! RenderBoxLayer).waitUntilAsyncRenderingCompleted()
    }

    override var isOpaque: Bool {
        get { super.isOpaque }
        set {
            layer.isOpaque = newValue
            super.isOpaque = newValue
        }
    }

    override func didMoveToWindow() {
        guard let window else { return }
        layer.contentsScale = window.screen.scale
        setNeedsDisplay()
    }

    override func setNeedsDisplay() {
        layer.setNeedsDisplay()
    }
}

extension RenderBoxView: RBLayerDelegate {
    func rbLayer(_ layer: RBLayer, draw inDisplayList: RBDisplayList) {
    }
}

// MARK: - RenderBoxLayer

private class RenderBoxLayer: RBLayer {
    override var needsSynchronousUpdate: Bool {
        get {
            guard super.needsSynchronousUpdate else {
                return false
            }
            guard let delegate = delegate as? RenderBoxView,
                  delegate.rendersFirstFrameAsynchronously
            else {
                return true
            }
            return hasBeenCommitted
        }
        set {
            super.needsSynchronousUpdate = newValue
        }
    }
}
#endif
