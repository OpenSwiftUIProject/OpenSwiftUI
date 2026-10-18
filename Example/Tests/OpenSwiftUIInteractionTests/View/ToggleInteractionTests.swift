//
//  ToggleInteractionTests.swift
//  OpenSwiftUIInteractionTests

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import Testing

@MainActor
@Suite(.serialized, .tags(.interaction))
struct ToggleInteractionTests {
    @Test
    func repeatedTapsUpdateBinding() async throws {
        var values: [Bool] = []
        let content = StatefulToggle { values.append($0) }

        try await withInteractionTestHost(of: content) { host in
            #expect(values.isEmpty)
            for count in 1...3 {
                try await host.tap()
                try await host.waitUntil(values.count >= count)
                // Let the native switch finish its animation before the next tap.
                try await Task.sleep(for: .milliseconds(600))
            }
            #expect(values == [true, false, true])
        }
    }

    @Test
    func disabledToggleDoesNotUpdateBinding() async throws {
        var values: [Bool] = []
        let content = StatefulToggle { values.append($0) }
            .disabled(true)

        try await withInteractionTestHost(of: content) { host in
            for _ in 0..<2 {
                try await host.tap()
                try await Task.sleep(for: .milliseconds(600))
            }
            #expect(values.isEmpty)
        }
    }

    private struct StatefulToggle: View {
        var onChange: (Bool) -> Void
        @State private var reset = false

        var body: some View {
            Toggle("Reset", isOn: Binding(
                get: { reset },
                set: {
                    reset = $0
                    onChange($0)
                }
            ))
            #if os(macOS)
            .toggleStyle(.switch)
            #endif
            .labelsHidden()
            .fixedSize()
        }
    }
}
