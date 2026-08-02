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

#Preview("HostingVC") {
    ContentView()
        ._previewVC()
}

#Preview("CAHostingLayerExample") {
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    CAHostingLayerExample(
        content: ContentView(),
        size: CGSize(width: 500, height: 300)
    ).makeViewController()
    #else
    CAHostingLayerExample(
        content: ContentView(),
        size: UIScreen.main.bounds.size
    ).makeViewController()
    #endif
}
