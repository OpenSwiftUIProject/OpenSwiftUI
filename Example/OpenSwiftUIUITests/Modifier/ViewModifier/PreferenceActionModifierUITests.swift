//
//  PreferenceActionModifierUITests.swift
//  OpenSwiftUIUITests

import Foundation
import Testing
@testable import TestingHost

private final class PreferenceActionRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var value: String?

    func record(value: String) {
        lock.lock()
        defer { lock.unlock() }
        self.value = value
    }

    func snapshot() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
}

private final class TransactionalPreferenceActionRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var value: String?
    private var disablesAnimations = false

    func record(value: String, disablesAnimations: Bool) {
        lock.lock()
        defer { lock.unlock() }
        self.value = value
        self.disablesAnimations = disablesAnimations
    }

    func snapshot() -> (value: String?, disablesAnimations: Bool) {
        lock.lock()
        defer { lock.unlock() }
        return (value, disablesAnimations)
    }
}

@MainActor
struct PreferenceActionModifierUITests {
    @Test
    func onPreferenceChange() {
        let recorder = PreferenceActionRecorder()
        let controller = AnimationDebugController(
            PreferenceActionModifierExample(action: { value in
                recorder.record(value: value)
            })
        )
        controller.advance(interval: .zero)
        #expect(recorder.snapshot() == "changed")
        withExtendedLifetime(controller) {}
    }

    @Test
    @available(iOS 18.2, macOS 15.2, *)
    func transactionalOnPreferenceChange() {
        let recorder = TransactionalPreferenceActionRecorder()
        let controller = AnimationDebugController(
            TransactionalPreferenceActionExample(action: { value, transaction in
                recorder.record(
                    value: value,
                    disablesAnimations: transaction.disablesAnimations
                )
            })
        )
        controller.advance(interval: .zero)
        let snapshot = recorder.snapshot()
        #expect(snapshot.value == "changed")
        #expect(snapshot.disablesAnimations)
        withExtendedLifetime(controller) {}
    }
}
