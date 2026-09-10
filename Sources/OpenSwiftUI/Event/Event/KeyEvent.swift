//
//  KeyEvent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
package import OpenSwiftUICore

// MARK: - KeyEvent

package protocol KeyEventProvider {
    func resolve(phase: EventPhase) -> KeyEvent?
}

package struct KeyEvent: NonGestureEventType, ModifiersEventType, Equatable {
    package var phase: EventPhase
    package var timestamp: Time
    package var binding: EventBinding?
    package var modifiers: EventModifiers
    package var keys: String
    package var stringValue: String
    package var keyID: AnyHashable

    package init(
        phase: EventPhase,
        timestamp: Time,
        binding: EventBinding? = nil,
        modifiers: EventModifiers,
        keys: String,
        stringValue: String,
        keyID: AnyHashable
    ) {
        self.phase = phase
        self.timestamp = timestamp
        self.binding = binding
        self.modifiers = modifiers
        self.keys = keys
        self.stringValue = stringValue
        self.keyID = keyID
    }

    package struct Tracker {
        package var activeVersions: [AnyHashable: DisplayList.Version] = [:]

        package init() {}

        package mutating func serial(for event: KeyEvent) -> Int {
            let version: DisplayList.Version
            switch event.phase {
            case .began:
                version = DisplayList.Version(forUpdate: ())
                activeVersions[event.keyID] = version
            case .active:
                if let activeVersion = activeVersions[event.keyID] {
                    version = activeVersion
                } else {
                    version = DisplayList.Version(forUpdate: ())
                    activeVersions[event.keyID] = version
                }
            case .ended, .failed:
                version = activeVersions.removeValue(forKey: event.keyID)
                    ?? DisplayList.Version(forUpdate: ())
            }
            return version.value
        }
    }
}
