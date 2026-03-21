//
//  PreviewShims.swift
//  Shared

import OpenSwiftUI
import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
extension SwiftUI.View {
    func _previewVC() -> some NSViewController {
        SwiftUI.NSHostingController(rootView: self)
    }
}
#else
import UIKit
extension SwiftUI.View {
    func _previewVC() -> some UIViewController {
        SwiftUI.UIHostingController(rootView: self)
    }
}
#endif

#if canImport(UIKit)
// FIXME: Not working on macOS yet

#Preview("HostingVC") {
    ContentView()
        ._previewVC()
}

#Preview("CAHostingLayerExample") {
    CAHostingLayerExample(
        content: ContentView(),
        size: UIScreen.main.bounds.size
    ).makeViewController()
}
#endif