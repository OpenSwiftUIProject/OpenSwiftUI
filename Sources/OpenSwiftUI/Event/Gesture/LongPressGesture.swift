//
//  LongPressGesture.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 95296CADE4B1B6231918FF94A8E7AAD1 (SwiftUI)

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - Gesture + longPressPhase [TBA]

extension Gesture {
    func longPressPhase() -> ModifierGesture<MapGesture<Value, Bool>, Self> {
        mapPhase { phase in
            if case .active = phase {
                .ended(true)
            } else {
                phase.withValue(false)
            }
        }
    }
}

// MARK: - Bool + PressableEventValue [TBA]

extension Bool: PressableEventValue {
    static func isPressing(_ phase: GesturePhase<Bool>) -> Bool {
        phase.unwrapped ?? false
    }
}
