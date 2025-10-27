//
//  HiddenModifierUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct HiddenModifierUITests {
    @Test
    func stackHidden() {
        struct ContentView: View {
            var body: some View {
                VStack(spacing: 0) {
                    Color.red
                    Color.green.hidden()
                    Color.blue
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
