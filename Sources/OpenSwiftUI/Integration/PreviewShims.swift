//
//  PreviewShims.swift
//  OpenSwiftUI
//
//  Bridging helpers for Xcode Preview support.
//  Wraps OpenSwiftUI views in hosting controllers
//  so they can be used with SwiftUI's #Preview macro.

import OpenSwiftUICore

// Helper method before we add fully preview thunk and preview macro support for OpenSwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
extension OpenSwiftUI.View {
    public func _previewVC() -> some NSViewController {
        OpenSwiftUI.NSHostingController(rootView: self)
    }
}
#else
import UIKit
extension OpenSwiftUI.View {
    public func _previewVC() -> some UIViewController {
        OpenSwiftUI.UIHostingController(rootView: self)
    }
}
#endif
