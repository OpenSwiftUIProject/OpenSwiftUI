//
//  AccessibilityTraitsAdditions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 478AFED66621CDE70653987BE563E31B (SwiftUI)

import OpenSwiftUICore
import OpenSwiftUI_SPI

// MARK: - AccessibilityTraitStorageProxy

@_spi(Ultraviolet)
@available(OpenSwiftUI_v3_0, *)
public struct AccessibilityTraitStorageProxy: Equatable, Hashable, Codable {
    var value: AccessibilityTraitStorage

    public init() {
        value = .init()
    }

    public var isDefault: Bool {
        value.isDefault
    }

    public var uv_descriptions: [String] {
        AccessibilityTrait.allCases.compactMap { trait in
            value[trait, default: false] ? trait.displayDescription : nil
        }
    }
}

@_spi(Ultraviolet)
@available(*, unavailable)
extension AccessibilityTraitStorageProxy: Sendable {}

// MARK: - AccessibilityTraitResolver

protocol AccessibilityTraitResolver {
    func resolve(into traits: inout AXOpenSwiftUITraits, for storage: AccessibilityTraitStorage)
}
