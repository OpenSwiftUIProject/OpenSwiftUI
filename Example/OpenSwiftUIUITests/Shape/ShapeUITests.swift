//
//  ShapeUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ShapeUITests {
    @Test
    func rectangle() {
        struct ContentView: View {
            var body: some View {
                Rectangle()
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
