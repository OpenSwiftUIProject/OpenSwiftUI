//
//  CAHostingLayerExample.swift
//  Shared

#if OPENSWIFTUI
#if canImport(UIKit)
@_spi(ForUIKitOnly) import OpenSwiftUI
#else
@_spi(ForAppKitOnly) import OpenSwiftUI
#endif
#else
#if canImport(UIKit)
@_spi(ForUIKitOnly) import SwiftUI_SPI
#else
@_spi(ForAppKitOnly) import SwiftUI_SPI
#endif
#endif

import QuartzCore

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

#if !OPENSWIFTUI
@available(iOS 18.0, macOS 15.0, *)
#endif
final class CAHostingLayerExampleView: PlatformView {
    private let hostingLayer: CALayer

    init(content: some View) {
        let hostingLayer = CAHostingLayer(rootView: content)
        self.hostingLayer = hostingLayer

        super.init(frame: .zero)

        hostingLayer.anchorPoint = .zero
        #if canImport(UIKit)
        layer.addSublayer(hostingLayer)
        #elseif canImport(AppKit)
        wantsLayer = true
        layer!.addSublayer(hostingLayer)
        #endif
        updateHostingLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if canImport(UIKit)
    override func layoutSubviews() {
        super.layoutSubviews()
        updateHostingLayer()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateHostingLayer()
    }
    #elseif canImport(AppKit)
    override func layout() {
        super.layout()
        updateHostingLayer()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateHostingLayer()
    }

    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        updateHostingLayer()
    }
    #endif

    private func updateHostingLayer() {
        #if canImport(UIKit)
        let contentsScale = window?.screen.scale
            ?? traitCollection.displayScale
        #elseif canImport(AppKit)
        let contentsScale = window?.backingScaleFactor
            ?? NSScreen.main?.backingScaleFactor
            ?? 1.0
        #endif

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        hostingLayer.frame = bounds
        if hostingLayer.contentsScale != contentsScale {
            hostingLayer.contentsScale = contentsScale
            hostingLayer.setNeedsLayout()
        }
        CATransaction.commit()
    }
}

#Preview("CAHostingLayerExampleView") {
    CAHostingLayerExampleView(content: ContentView())
}

#if !OPENSWIFTUI
@available(iOS 18.0, macOS 15.0, *)
#endif
struct CAHostingLayerExample<Content: View>: PlatformViewRepresentable {
    let content: Content

    #if canImport(UIKit)
    func makeUIView(context: Context) -> CAHostingLayerExampleView {
        CAHostingLayerExampleView(content: content)
    }

    func updateUIView(_ uiView: CAHostingLayerExampleView, context: Context) {}
    #elseif canImport(AppKit)
    func makeNSView(context: Context) -> CAHostingLayerExampleView {
        CAHostingLayerExampleView(content: content)
    }

    func updateNSView(_ nsView: CAHostingLayerExampleView, context: Context) {}
    #endif
}

#Preview("CAHostingLayerExample") {
    CAHostingLayerExample(content: ContentView())
}
