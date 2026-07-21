//
//  AttributeCountInfoKey.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - AttributeCountInfoKey

package struct AttributeCountInfoKey: HostPreferenceKey {
    package static let defaultValue = AttributeCountTestInfo()

    package static func reduce(
        value: inout AttributeCountTestInfo,
        nextValue: () -> AttributeCountTestInfo
    ) {
        value.merge(nextValue())
    }
}
