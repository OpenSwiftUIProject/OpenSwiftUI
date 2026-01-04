//
//  DisplayListViewDrawing.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 65A81BD07F0108B0485D2E15DE104A75 (SwiftUI)

#if canImport(Darwin)

@_spi(DisplayList_ViewSystem)
import OpenSwiftUICore
import QuartzCore
import OpenRenderBoxShims

#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - CGDrawingView

final class CGDrawingView: PlatformGraphicsView, PlatformDrawable {
    var options: PlatformDrawableOptions
    
    init(options: PlatformDrawableOptions) {
        self.options = options
        super.init(frame: .zero)
        isOpaque = options.isOpaque
        layer.contentsFormat = options.caLayerContentsFormat
    }

    required init?(coder: NSCoder) {
        _openSwiftUIUnreachableCode()
    }
    
    override class var layerClass: AnyClass {
        CGDrawingLayer.self
    }
    
    static var allowsContentsMultiplyColor: Bool {
        true
    }
    
    func update(content: PlatformDrawableContent?, required: Bool) -> Bool {
        let layer = layer as! CGDrawingLayer
        if let content {
            layer.content = content
        }
        layer.setNeedsDisplay()
        return true
    }

    func makeAsyncUpdate(content: PlatformDrawableContent, required: Bool, layer: CALayer, bounds: CGRect) -> (() -> Void)? {
        return nil
    }

    func setContentsScale(_ scale: CGFloat) {
        layer.contentsScale = scale
    }
    
    func drawForTesting(in displayList: ORBDisplayList) {
        var state = PlatformDrawableContent.State()
        let layer = layer as! CGDrawingLayer
        layer.content.draw(in: displayList, size: bounds.size, state: &state)
    }
}

// MARK: - CGDrawingLayer

private final class CGDrawingLayer: CALayer {
    var content: PlatformDrawableContent = .init()
    var state: PlatformDrawableContent.State = .init()
    
    override func draw(in ctx: CGContext) {
        content.draw(
            in: ctx,
            size: bounds.size,
            contentsScale: contentsScale,
            state: &state
        )
    }
}

// MARK: - RBDrawingView [WIP]

final class RBDrawingView: RenderBoxView, PlatformDrawable {
    var options: PlatformDrawableOptions {
        didSet {
            guard oldValue != options else {
                return
            }
            updateOptions()
        }
    }

    private struct State {
        var content: PlatformDrawableContent = .init()
        var renderer: PlatformDrawableContent.State = .init()
    }
    
    @AtomicBox
    private var state: RBDrawingView.State = .init()
    
    init(options: PlatformDrawableOptions) {
        self.options = options
        super.init(frame: .zero)
        updateOptions()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func updateOptions() {
        isOpaque = options.isOpaque
        options.update(rbLayer: layer)
        rendersFirstFrameAsynchronously = options.rendersFirstFrameAsynchronously
    }
    
    static var allowsContentsMultiplyColor: Bool {
        _openSwiftUIUnimplementedFailure()
    }

    func update(content: PlatformDrawableContent?, required: Bool) -> Bool {
        _openSwiftUIUnimplementedFailure()

    }

    func makeAsyncUpdate(content: PlatformDrawableContent, required: Bool, layer: CALayer, bounds: CGRect) -> (() -> Void)? {
        _openSwiftUIUnimplementedFailure()

    }

    func setContentsScale(_ scale: CGFloat) {
        _openSwiftUIUnimplementedFailure()

    }

    func drawForTesting(in: ORBDisplayList) {
        _openSwiftUIUnimplementedFailure()

    }
}

#endif

