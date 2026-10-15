//
//  DragGestureInteractionTests.swift
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
@Suite(.serialized, .tags(.interaction), .snapshots(record: .never, diffTool: diffTool))
struct DragGestureInteractionTests {
    private struct ContentView: View {
        var minimumDistance: Double
        var onChanged: (DragGesture.Value) -> Void
        var onEnded: (DragGesture.Value) -> Void

        var body: some View {
            Color.red
                .gesture(
                    DragGesture(minimumDistance: minimumDistance)
                        .onChanged { onChanged($0) }
                        .onEnded { onEnded($0) }
                )
        }
    }

    @Test
    func dragReportsTranslation() async throws {
        var changedCount = 0
        var endedValue: DragGesture.Value?
        let content = ContentView(
            minimumDistance: 10.0,
            onChanged: { _ in changedCount += 1 },
            onEnded: { endedValue = $0 }
        )
        try await withInteractionTestHost(of: content) { host in
            try await host.drag(by: CGSize(width: 60, height: 0))
            try await host.waitUntil(endedValue != nil)
            let value = try #require(endedValue)
            #expect(changedCount > 0)
            #expect(abs(value.translation.width - 60) < 1)
            #expect(abs(value.translation.height) < 1)
            #expect(abs(value.location.x - value.startLocation.x - 60) < 1)
        }
    }

    // With Hammer's synthetic AppKit drag events, SwiftUI also starts the drag at the
    // first event, so only touches can show the minimum distance.
    #if os(iOS)
    @Test
    func dragStartsAfterMinimumDistance() async throws {
        var changedValues: [DragGesture.Value] = []
        var endedValues: [DragGesture.Value] = []
        let content = ContentView(
            minimumDistance: 10.0,
            onChanged: { changedValues.append($0) },
            onEnded: { endedValues.append($0) }
        )
        try await withInteractionTestHost(of: content) { host in
            // A drag shorter than the default minimum distance must not start the gesture.
            try await host.drag(by: CGSize(width: 4, height: 0), duration: 0.1)
            try await host.drag(by: CGSize(width: 60, height: 0))
            try await host.waitUntil(!endedValues.isEmpty)
            #expect(endedValues.count == 1)
            let firstChange = try #require(changedValues.first)
            #expect(firstChange.translation.width >= 10)
        }
    }
    #endif
}
