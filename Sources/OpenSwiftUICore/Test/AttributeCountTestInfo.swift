//
//  AttributeCountTestInfo.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - AttributeCountTestInfo [6.4.41]

package struct AttributeCountTestInfo: Equatable {
    var attributeCounts: [String: UInt32] = [:]
    var updateCounts: [String: UInt32] = [:]
    var changeCounts: [String: UInt32] = [:]
    var history: [String: UInt32] = [:]

    mutating func merge(_ other: AttributeCountTestInfo) {
        attributeCounts.merge(other.attributeCounts) { $0 + $1 }
        updateCounts.merge(other.updateCounts) { $0 + $1 }
        changeCounts.merge(other.changeCounts) { $0 + $1 }
        history.merge(other.history) { $0 + $1 }
    }
}

// MARK: - AttributeCountInfoKey [6.4.41]

package struct AttributeCountInfoKey: HostPreferenceKey {
    package static let defaultValue = AttributeCountTestInfo()

    package static func reduce(
        value: inout AttributeCountTestInfo,
        nextValue: () -> AttributeCountTestInfo
    ) {
        value.merge(nextValue())
    }
}

