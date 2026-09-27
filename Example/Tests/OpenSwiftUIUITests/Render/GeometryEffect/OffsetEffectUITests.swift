//
//  OffsetEffectUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct OffsetEffectUITests {
    @Test
    func offsetWithFrame() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .offset(x: 20, y: 15)
                    .frame(width: 80, height: 60)
                    .background(Color.red)
                    .overlay(Color.green.offset(x: 40, y: 30))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
