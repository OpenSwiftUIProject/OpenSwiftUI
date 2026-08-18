//
//  ModifierKeySource.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C1EF23D99744ECA2CC2F9818A6F315B1 (SwiftUI)

import Foundation
import OpenSwiftUICore

// MARK: - ModifierKeySource

package protocol ModifierKeySource {
    static var monitor: ModifierKeyMonitor { get }
    var current: EventModifiers { get }
    var values: any AsyncSequence { get }
}

// MARK: - ModifierKeyMonitor

package final class ModifierKeyMonitor {
    private var observers: [UUID: (EventModifiers) -> Void] = [:]

    private var value: EventModifiers = [] {
        didSet {
            guard value != oldValue else {
                return
            }
            for observer in observers.values {
                observer(value)
            }
        }
    }

    var current: EventModifiers { value }

    @discardableResult
    func addObserver(_ observer: @escaping (EventModifiers) -> Void) -> UUID {
        let id = UUID()
        observers[id] = observer
        return id
    }

    func removeObserver(id: UUID) {
        observers[id] = nil
    }

    func observe(_ modifiers: EventModifiers) {
        value = modifiers
    }

    func resume() {
        // FIXME
        _openSwiftUIUnimplementedWarning()
    }

    func suspend() {
        // FIXME
        _openSwiftUIUnimplementedWarning()
    }
}

// MARK: - DefaultModifierKeySource

struct DefaultModifierKeySource: ModifierKeySource {
    static let monitor = ModifierKeyMonitor()

    var current: EventModifiers { Self.monitor.current }

    var values: any AsyncSequence {
        AsyncStream<EventModifiers> { continuation in
            let id = Self.monitor.addObserver { modifiers in
                continuation.yield(modifiers)
            }
            continuation.onTermination = { t in
                Task { @MainActor in
                    Self.monitor.removeObserver(id: id)
                }
            }
            return
        }
    }
}
