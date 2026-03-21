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
import SwiftUI_SPI
#endif

import QuartzCore

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@MainActor
struct CAHostingLayerExample<Content: View> {
    var content: Content
    var size: CGSize

    #if !OPENSWIFTUI
    @available(iOS 18.0, macOS 15.0, *)
    #endif
    func makeViewController() -> PlatformViewController {
        let layer = CAHostingLayer(rootView: content)
        layer.anchorPoint = .zero
        layer.bounds = CGRect(origin: .zero, size: size)
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        let view = NSView(frame: CGRect(origin: .zero, size: size))
        view.wantsLayer = true
        view.layer?.addSublayer(layer)
        let vc = NSViewController()
        vc.view = view
        #elseif canImport(UIKit)
        let view = UIView(frame: CGRect(origin: .zero, size: size))
        view.layer.addSublayer(layer)
        let vc = UIViewController()
        vc.view = view
        #endif
        return vc
    }
}
