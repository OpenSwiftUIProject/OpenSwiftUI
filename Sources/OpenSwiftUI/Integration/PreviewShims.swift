//
//  PreviewShims.swift
//  OpenSwiftUI
//
//  Bridging helpers for Xcode Preview support.
//  Presents OpenSwiftUI views as SwiftUI previews for the #Preview macro.

import OpenSwiftUICore

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
public import AppKit
extension OpenSwiftUI.View {
    @available(*, deprecated, message: "Use the OpenSwiftUI #Preview macro or PreviewProvider instead.")
    public func _previewVC() -> NSViewController {
        OpenSwiftUI.NSHostingController(rootView: self)
    }
}
#elseif canImport(UIKit)
public import UIKit
extension OpenSwiftUI.View {
    @available(*, deprecated, message: "Use the OpenSwiftUI #Preview macro or PreviewProvider instead.")
    public func _previewVC() -> UIViewController {
        OpenSwiftUI.UIHostingController(rootView: self)
    }
}
#endif

#if canImport(DeveloperToolsSupport) && canImport(SwiftUI) && (os(macOS) || os(iOS) || os(visionOS))
public import DeveloperToolsSupport
import SwiftUI

@available(iOS 17.0, macOS 14.0, visionOS 1.0, *)
extension DeveloperToolsSupport.Preview {
    /// Creates a preview of an OpenSwiftUI view.
    ///
    /// - Parameters:
    ///   - name: An optional display name for the preview.
    ///   - traits: An optional list of traits that customize the preview.
    ///   - body: A closure that produces the OpenSwiftUI view to preview.
    @MainActor
    public init(
        _ name: String? = nil,
        traits: PreviewTrait<Preview.ViewTraits>...,
        body: @escaping @MainActor () -> any OpenSwiftUI.View
    ) {
        // Swift cannot forward a variadic list, so combine the traits first.
        let trait = traits.reduce(PreviewTrait()) { PreviewTrait($0, $1) }
        self.init(name, traits: trait) {
            NativePreviewView(content: OpenSwiftUI.AnyView(body()))
        }
    }
}
#endif
