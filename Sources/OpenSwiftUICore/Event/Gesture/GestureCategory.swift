//
//  GestureCategory.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import OpenAttributeGraphShims

// MARK: - GestureCategory

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public struct GestureCategory: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    package static let magnify: GestureCategory = .init(rawValue: 1 << 0)

    package static let rotate: GestureCategory = .init(rawValue: 1 << 1)

    package static let drag: GestureCategory = .init(rawValue: 1 << 2)

    package static let select: GestureCategory = .init(rawValue: 1 << 3)

    package static let longPress: GestureCategory = .init(rawValue: 1 << 4)

    package struct Key: PreferenceKey {
        package static let _includesRemovedValues: Bool = true

        package static let defaultValue: GestureCategory = .defaultValue

        package static func reduce(
            value: inout GestureCategory.Key.Value,
            nextValue: () -> GestureCategory.Key.Value
        ) {
            value.formUnion(nextValue())
        }
    }
}

@available(*, unavailable)
extension GestureCategory: Sendable {}

// MARK: - PreferencesInputs + GestureCategory

extension PreferencesInputs {
    @inline(__always)
    var containsGestureCategory: Bool {
        contains(GestureCategory.Key.self)
    }
}

// MARK: - PreferencesOutputs + GestureCategory

extension PreferencesOutputs {
    @inline(__always)
    var gestureCategory: Attribute<GestureCategory>? {
        get { self[GestureCategory.Key.self] }
        set { self[GestureCategory.Key.self] = newValue }
    }
}
