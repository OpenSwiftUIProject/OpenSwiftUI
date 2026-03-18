//
//  PreviewShims.swift
//  Shared

import OpenSwiftUI
import SwiftUI

// Helper method before we add fully preview thunk and preview macro support for OpenSwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
extension OpenSwiftUI.View {
    func _previewVC() -> some NSViewController {
        OpenSwiftUI.NSHostingController(rootView: self)
    }
}
extension SwiftUI.View {
    func _previewVC() -> some NSViewController {
        SwiftUI.NSHostingController(rootView: self)
    }
}
#else
import UIKit
extension OpenSwiftUI.View {
    func _previewVC() -> some UIViewController {
        OpenSwiftUI.UIHostingController(rootView: self)
    }
}
extension SwiftUI.View {
    func _previewVC() -> some UIViewController {
        SwiftUI.UIHostingController(rootView: self)
    }
}
#endif

#Preview {
    // FIXME: Not working on macOS yet
    ContentView()
        ._previewVC()
}
