//
//  PreviewShims.swift
//  OpenSwiftUI
//
//  Bridging helpers for Xcode Preview support.
//  Wraps OpenSwiftUI views in hosting controllers so they can be used with
//  AppKit and UIKit's #Preview macros.

import OpenSwiftUICore

// Helper method before we add native preview thunk support for OpenSwiftUI.

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
public import AppKit
extension OpenSwiftUI.View {
    public func _previewVC() -> NSViewController {
        OpenSwiftUI.NSHostingController(rootView: self)
    }
}
#elseif canImport(UIKit)
public import UIKit
extension OpenSwiftUI.View {
    public func _previewVC() -> UIViewController {
        OpenSwiftUI.UIHostingController(rootView: self)
    }
}
#endif
