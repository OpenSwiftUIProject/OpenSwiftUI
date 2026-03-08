//
//  Image+Accessibility.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 850D6677B8CDB42F6FE21E92D1B9BAE5 (SwiftUICore)

package protocol ImageAccessibilityProvider {
    associatedtype Body: View

    static func makeView(image: Image, resolved: Image.Resolved) -> Body
}

struct EmptyImageAccessibilityProvider: ImageAccessibilityProvider {
    static func makeView(image: Image, resolved: Image.Resolved) -> some View {
        resolved
    }
}

extension _GraphInputs {
    private struct ImageAccessibilityProviderKey: GraphInput {
        static let defaultValue: (any ImageAccessibilityProvider.Type) = EmptyImageAccessibilityProvider.self
    }

    package var imageAccessibilityProvider: (any ImageAccessibilityProvider.Type) {
        get { self[ImageAccessibilityProviderKey.self] }
        set { self[ImageAccessibilityProviderKey.self] = newValue }
    }
}

extension _ViewInputs {
    package var imageAccessibilityProvider: (any ImageAccessibilityProvider.Type) {
        get { base.imageAccessibilityProvider }
        set { base.imageAccessibilityProvider = newValue }
    }
}
