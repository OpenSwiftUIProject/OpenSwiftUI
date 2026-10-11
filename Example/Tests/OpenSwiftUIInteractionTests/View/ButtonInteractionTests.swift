//
//  ButtonInteractionTests.swift
//  OpenSwiftUIInteractionTests

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.serialized, .tags(.interaction), .snapshots(record: .never, diffTool: diffTool))
struct ButtonInteractionTests {
    @Test
    func actionUpdatesCount() async throws {
        var counts: [Int] = []
        let content = ButtonExample { counts.append($0) }

        try await withInteractionTestHost(of: content) { host in
            #expect(counts.isEmpty)
            try await host.assertSnapshot(named: "initial")

            for count in 1...2 {
                try await host.tap()
                try await host.waitUntil(counts.count >= count)
                // Capture the idle appearance after the button's release animation.
                try await Task.sleep(for: .milliseconds(600))
                try await host.assertSnapshot(named: "tap-\(count)")
                #expect(counts == Array(1...count))
            }
        }
    }

    @Test
    func disabledButtonDoesNotRunAction() async throws {
        var counts: [Int] = []
        let content = ButtonExample { counts.append($0) }
            .disabled(true)

        try await withInteractionTestHost(of: content) { host in
            try await host.assertSnapshot(named: "initial")

            for count in 1...2 {
                try await host.tap()
                try await Task.sleep(for: .milliseconds(600))
                try await host.assertSnapshot(named: "tap-\(count)")
                #expect(counts.isEmpty)
            }
        }
    }
}
