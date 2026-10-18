//
//  LegacyPreviewProvider.swift
//  OpenSwiftUI

#if canImport(SwiftUI) && (os(macOS) || os(iOS) || os(visionOS))
import OpenSwiftUICore
import SwiftUI

@_silgen_name("_OpenSwiftUI_LegacyPreviewProviderWitnessType")
func legacyPreviewProviderWitnessType() -> Any.Type {
    LegacyPreviewProviderWitness.self
}

// PreviewProvider.m copies this class's native witness tables for each OSUI
// provider. Keep the class non-final: its static getters must use the caller's
// metatype, not the template type. The associated view type is always AnyView.
private class LegacyPreviewProviderWitness: SwiftUI.PreviewProvider {
    private static var provider: any OpenSwiftUI._PreviewProvider.Type {
        guard let provider = (self as Any.Type) as? any OpenSwiftUI._PreviewProvider.Type else {
            Swift.preconditionFailure("Expected an OpenSwiftUI preview provider")
        }
        return provider
    }

    static var previews: SwiftUI.AnyView {
        SwiftUI.AnyView(
            SwiftUI.ForEach(provider._allPreviews, id: \.id) { preview in
                nativePreview(preview)
            }
        )
    }

    static var platform: SwiftUI.PreviewPlatform? {
        switch provider._platform {
        case .iOS: .iOS
        case .macOS: .macOS
        case .tvOS: .tvOS
        case .watchOS: .watchOS
        case nil: nil
        }
    }

    static var _previews: Any { previews }

    static var _platform: SwiftUI.PreviewPlatform? { platform }

    private static func nativePreview(_ preview: OpenSwiftUI._Preview) -> SwiftUI.AnyView {
        var view = SwiftUI.AnyView(
            NativePreviewView(content: preview.content)
                .previewDisplayName(preview.displayName)
                .previewDevice(preview.device.map { SwiftUI.PreviewDevice(rawValue: $0.rawValue) })
                .previewLayout(preview.layout)
        )
        if #available(iOS 14.0, macOS 11.0, *), let context = preview.context {
            let nativeContext = (context as? any SwiftUI.PreviewContext)
                ?? LegacyPreviewContext(context: context)
            view = SwiftUI.AnyView(view.previewContext(nativeContext))
        }
        if #available(iOS 14.5, macOS 11.3, *) {
            let colorScheme: SwiftUI.ColorScheme? = preview.colorScheme.map {
                $0 == .dark ? .dark : .light
            }
            view = SwiftUI.AnyView(view.preferredColorScheme(colorScheme))
        }
        if #available(iOS 15.0, macOS 12.0, *),
           let orientation = SwiftUI.InterfaceOrientation.allCases.first(where: {
               $0.id == preview.interfaceOrientation.id
           }) {
            view = SwiftUI.AnyView(view.previewInterfaceOrientation(orientation))
        }
        return view
    }
}

@available(iOS 14.0, macOS 11.0, *)
private struct LegacyPreviewContext: OpenSwiftUI.PreviewContext, SwiftUI.PreviewContext {
    var context: any OpenSwiftUI.PreviewContext

    subscript<Key: OpenSwiftUI.PreviewContextKey>(key: Key.Type) -> Key.Value {
        context[key]
    }

    subscript<Key: SwiftUI.PreviewContextKey>(key: Key.Type) -> Key.Value {
        // Preserve key identity; a wrapper key would lose type-specific values.
        guard let key = key as? any OpenSwiftUI.PreviewContextKey.Type else {
            return Key.defaultValue
        }
        func value<K: OpenSwiftUI.PreviewContextKey>(_ key: K.Type) -> Any {
            context[key]
        }
        return value(key) as? Key.Value ?? Key.defaultValue
    }
}

#if (os(iOS) || os(visionOS))
struct NativePreviewView: SwiftUI.UIViewControllerRepresentable {
    var content: OpenSwiftUI.AnyView

    func makeUIViewController(context: Context) -> OpenSwiftUI.UIHostingController<OpenSwiftUI.AnyView> {
        OpenSwiftUI.UIHostingController(rootView: content)
    }

    func updateUIViewController(
        _ controller: OpenSwiftUI.UIHostingController<OpenSwiftUI.AnyView>,
        context: Context
    ) {
        controller.rootView = content
    }

    @available(iOS 16.0, *)
    func sizeThatFits(
        _ proposal: SwiftUI.ProposedViewSize,
        uiViewController controller: OpenSwiftUI.UIHostingController<OpenSwiftUI.AnyView>,
        context: Context
    ) -> CGSize? {
        // The controller's CGSize API cannot preserve unspecified dimensions.
        controller.host.sizeThatFits(.init(width: proposal.width, height: proposal.height))
    }
}
#elseif os(macOS)
struct NativePreviewView: SwiftUI.NSViewControllerRepresentable {
    var content: OpenSwiftUI.AnyView

    func makeNSViewController(context: Context) -> OpenSwiftUI.NSHostingController<OpenSwiftUI.AnyView> {
        OpenSwiftUI.NSHostingController(rootView: content)
    }

    func updateNSViewController(
        _ controller: OpenSwiftUI.NSHostingController<OpenSwiftUI.AnyView>,
        context: Context
    ) {
        controller.rootView = content
    }

    @available(macOS 13.0, *)
    func sizeThatFits(
        _ proposal: SwiftUI.ProposedViewSize,
        nsViewController controller: OpenSwiftUI.NSHostingController<OpenSwiftUI.AnyView>,
        context: Context
    ) -> CGSize? {
        // The controller's CGSize API cannot preserve unspecified dimensions.
        controller.host.sizeThatFits(.init(width: proposal.width, height: proposal.height))
    }
}
#endif
#endif
