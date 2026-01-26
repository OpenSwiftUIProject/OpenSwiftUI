//
//  ViewIdentity.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 40EF7F17DC5632BC606B35EF926A7EA5 (SwiftUI)

import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - ViewIdentity

package struct ViewIdentity: Hashable {
    package let seed: UInt32

    private static var nextSeed: UInt32 = 1

    package static let invalid = ViewIdentity(seed: .zero)

    package init() {
        let seed = ViewIdentity.nextSeed
        let next = seed &+ 1
        ViewIdentity.nextSeed = seed <= 1 ? 1 : next
        self.init(seed: seed)
    }

    private init(seed: UInt32) {
        self.seed = seed
    }

    package struct Tracker {
        package var id: ViewIdentity
        package var resetSeed: UInt32

        package mutating func update(
            for phase: ViewPhase
        ) -> (value: ViewIdentity, changed: Bool) {
            guard phase.resetSeed != resetSeed || id == .invalid else {
                return (id, false)
            }
            id = .init()
            resetSeed = phase.resetSeed
            return (id, true)
        }
    }
}

// MARK: - IdentityLink

package struct IdentityLink: DynamicProperty {
    var _value: ViewIdentity

    package static func _makeProperty<Value>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<Value>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        let box = IdentityLinkBox(id: .invalid)
        buffer.append(box, fieldOffset: fieldOffset)
    }
}

// MARK: - IdentityLinkBox

private struct IdentityLinkBox: DynamicPropertyBox {
    var id: ViewIdentity

    mutating func reset() {
        id = .invalid
    }

    mutating func update(
        property: inout IdentityLink,
        phase: ViewPhase
    ) -> Bool {
        let newID = id == .invalid ? ViewIdentity() : id
        property._value = newID
        defer { id = newID }
        return newID != id
    }
}
