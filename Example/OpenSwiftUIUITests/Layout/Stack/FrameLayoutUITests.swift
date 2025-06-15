//
//  FrameLayoutUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct FrameLayoutUITests {
    @Test
    func noFrame() {
        struct ContentView: View {
            var body: some View {
                Color.red.frame()
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func frameSize() {
        struct ContentView: View {
            var body: some View {
                Color.red.frame(width: 50, height: 50)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
