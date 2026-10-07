//
//  AccessibilityVisibility.swift
//  OpenSwiftUI
//
//  Audited for iOS and macOS 6.5.4
//  Status: Complete
//  ID: 02E11489BF481D947C058EF31FF8B42A (SwiftUI?)

@_spi(Private)
import OpenSwiftUICore

extension View {
    func accessibilityDisabled() -> some View {
        modifier(DisableAccessibilityNodesModifier())
            .environment(\.accessibilityEnabled, false)
    }
}

@_spi(Ultraviolet)
@available(OpenSwiftUI_v3_0, *)
public struct AccessibilityVisibilityStorageProxy: Equatable, Hashable, Codable {
    var value: AccessibilityVisibilityStorage

    public init() {
        value = .init()
    }

    public var isElement: Bool? {
        value[.element]
    }

    public var isContainer: Bool? {
        value[.container]
    }

    public var resolvesToHidden: Bool {
        value.resolvesToHidden
    }

    public var isDefault: Bool {
        value.isDefault
    }
}

@_spi(Ultraviolet)
@available(*, unavailable)
extension AccessibilityVisibilityStorageProxy: Sendable {}

private struct DisableAccessibilityNodesModifier: ViewInputsModifier {
    nonisolated static func _makeViewInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs.preferences.remove(AccessibilityNodesKey.self)
    }
}
