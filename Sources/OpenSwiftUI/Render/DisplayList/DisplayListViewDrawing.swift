//
//  DisplayListViewDrawing.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by RBDrawingView
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
    var options: PlatformDrawableOptions {
        didSet {
            guard oldValue != options else {
                return
            }
            updateOptions()
        }
    }

    private func updateOptions() {
        #if os(iOS) || os(visionOS)
        isOpaque = options.isOpaque
        layer.contentsFormat = options.caLayerContentsFormat
        #elseif os(macOS)
        layer!.isOpaque = options.isOpaque
        layer!.contentsFormat = options.caLayerContentsFormat
        #endif
    }

    init(options: PlatformDrawableOptions) {
        self.options = options
        super.init(frame: .zero)
        #if os(macOS)
        wantsLayer = true
        layer = CGDrawingLayer()
        #endif
        updateOptions()
    }

    required init?(coder: NSCoder) {
        _openSwiftUIUnreachableCode()
    }

    #if os(iOS) || os(visionOS)
    override class var layerClass: AnyClass {
        CGDrawingLayer.self
    }
    #endif

    #if os(macOS)
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current,
              !context.isDrawingToScreen
        else { return }
        let layer = layer as! CGDrawingLayer
        layer.content
            .draw(
                in: context.cgContext,
                size: bounds.size,
                contentsScale: layer.contentsScale,
                state: &layer.state
            )
    }
    #endif

    static var allowsContentsMultiplyColor: Bool {
        true
    }
    
    func update(
        content: PlatformDrawableContent?,
        required: Bool
    ) -> Bool {
        let layer = layer as! CGDrawingLayer
        if let content {
            layer.content = content
        }
        #if os(iOS) || os(visionOS)
        setNeedsDisplay()
        #elseif os(macOS)
        needsDisplay = true
        #endif
        return true
    }

    func makeAsyncUpdate(
        content: PlatformDrawableContent,
        required: Bool,
        layer: CALayer,
        bounds: CGRect
    ) -> (() -> Void)? {
        nil
    }

    func setContentsScale(_ scale: CGFloat) {
        #if os(iOS) || os(visionOS)
        layer.contentsScale = scale
        #elseif os(macOS)
        layer!.contentsScale = scale
        #endif
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

    private func updateOptions() {
        isOpaque = options.isOpaque
        #if os(iOS) || os(visionOS)
        options.update(rbLayer: layer)
        #elseif os(macOS)
        options.update(rbLayer: layer!)
        #endif
        rendersFirstFrameAsynchronously = options.rendersFirstFrameAsynchronously
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
        _openSwiftUIUnreachableCode()
    }
    
    static var allowsContentsMultiplyColor: Bool {
        false
    }

    func update(
        content: PlatformDrawableContent?,
        required: Bool
    ) -> Bool {
        guard required || !options.rendersAsynchronously || (layer as! ORBLayer).isDrawableAvailable else {
            return false
        }
        if let content {
            state.content = content
        }
        #if os(iOS) || os(visionOS)
        layer.setNeedsDisplay()
        #elseif os(macOS)
        needsDisplay = true
        #endif
        return true
    }

    func makeAsyncUpdate(
        content: PlatformDrawableContent,
        required: Bool,
        layer: CALayer,
        bounds: CGRect
    ) -> (() -> Void)? {
        let layer = layer as! ORBLayer
        guard required || !options.rendersAsynchronously || !layer.isDrawableAvailable else {
            return nil
        }
        return {
            _openSwiftUIUnimplementedFailure()
        }
    }

    func setContentsScale(_ scale: CGFloat) {
        #if os(iOS) || os(visionOS)
        layer.contentsScale = scale
        #elseif os(macOS)
        layer!.contentsScale = scale
        #endif
    }

    func drawForTesting(in displayList: ORBDisplayList) {
        var s = PlatformDrawableContent.State()
        state.content.draw(in: displayList, size: bounds.size, state: &s)
    }

    override func draw(inDisplayList displayList: ORBDisplayList) {
        draw(in: displayList, size: bounds.size)
    }

    private func draw(in displayList: ORBDisplayList, size: CGSize) {
        _openSwiftUIUnimplementedFailure()
    }
}

#endif

