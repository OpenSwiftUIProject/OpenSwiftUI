//
//  TapGestureInteractionTests.swift
//  OpenSwiftUIInteractionTests

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import OpenSwiftUITestsSupport
import SnapshotTesting
import Testing

@MainActor
@Suite(.tags(.interaction), .snapshots(record: .never, diffTool: diffTool))
struct TapGestureInteractionTests {
    @Test(arguments: [1, 2])
    func onTapGestureIncrementsCount(tapCount: Int) async throws {
        struct ContentView: View {
            var tapCount: Int
            var onTap: () -> Void
            @State private var isGreen = false

            var body: some View {
                Color(.sRGB, red: isGreen ? 0 : 1, green: isGreen ? 1 : 0, blue: 0)
                    .onTapGesture(count: tapCount) {
                        isGreen.toggle()
                        onTap()
                    }
            }
        }

        var count = 0
        let content = ContentView(tapCount: tapCount) { count += 1 }
        try await withInteractionTestHost(of: content, size: .init(width: 300, height: 200)) { host in
            #expect(count == 0)
            try await host.assertSnapshot(named: "tap-\(tapCount)-initial")
            try await host.tap(count: tapCount)
            try await host.waitUntil(count > 0)
            #expect(count == 1)
            try await host.assertSnapshot(named: "tap-\(tapCount)-changed")

            try await host.tap(count: tapCount)
            try await host.waitUntil(count > 1)
            #expect(count == 2)
            try await host.assertSnapshot(named: "tap-\(tapCount)-restored")
        }
    }
}
