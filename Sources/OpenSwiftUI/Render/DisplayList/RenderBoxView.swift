//
//  RenderBoxView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 0CB954C9DC99A8A907C58D7882F9389E (SwiftUI)

#if canImport(Darwin)
import COpenSwiftUI
import Foundation
import QuartzCore
import QuartzCore_Private
import OpenRenderBoxShims

// MARK: - RenderBoxView

@objc
class RenderBoxView: PlatformGraphicsView {
    var rendersFirstFrameAsynchronously: Bool

    #if os(iOS) || os(visionOS)
    override class var layerClass: AnyClass {
        RenderBoxLayer.self
    }
    #endif

    private func rbInit() {
        #if os(iOS) || os(visionOS)
        let layer = layer
        layer.delegate = self
        layer.isOpaque = isOpaque
        #elseif os(macOS)
        wantsLayer = true
        layer = RenderBoxLayer()
        layerContentsRedrawPolicy = .duringViewResize
        let layer = layer!
        layer.delegate = self
        layer.isOpaque = isOpaque
        #endif
    }

    override init(frame: CGRect) {
        rendersFirstFrameAsynchronously = false
        super.init(frame: frame)
        rbInit()
    }
    
    required init?(coder: NSCoder) {
        rendersFirstFrameAsynchronously = false
        super.init(coder: coder)
        rbInit()
    }

    deinit {
        (layer as! RenderBoxLayer).waitUntilAsyncRenderingCompleted()
    }

    #if os(iOS) || os(visionOS)
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
    #elseif os(macOS)
    override func viewDidMoveToWindow() {
        guard let window else { return }
        layer?.contentsScale = window.backingScaleFactor
        needsDisplay = true
    }
    #endif

    func draw(inDisplayList displayList: ORBDisplayList) {
        _openSwiftUIEmptyStub()
    }
}

extension RenderBoxView: ORBLayerDelegate {
    func rbLayer(_ layer: ORBLayer, draw inDisplayList: ORBDisplayList) {
        draw(inDisplayList: inDisplayList)
    }

    #if os(macOS)
    func rbLayerDefaultDevice(_ layer: ORBLayer) -> ORBDevice? {
        let id = _NSWindowGetCGDisplayID(window)
        guard id != 0 else {
            return nil
        }
        return ORBDevice.sharedDevice(forDisplay: id)
    }
    #endif
}

// MARK: - RenderBoxLayer

private class RenderBoxLayer: ORBLayer {
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
