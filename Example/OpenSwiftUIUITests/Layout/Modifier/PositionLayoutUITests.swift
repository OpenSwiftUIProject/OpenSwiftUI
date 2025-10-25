//
//  PositionLayoutUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct PositionLayoutUITests {
    @Test
    func positionInZStack() {
        struct ContentView: View {
            var body: some View {
                ZStack {
                    Color.red
                        .frame(width: 50, height: 50)
                        .position()
                    Color.green
                        .frame(width: 50, height: 50)
                        .position(x: 50)
                    Color.blue
                        .frame(width: 50, height: 50)
                        .position(y: 50)
                    Color.black
                        .frame(width: 50, height: 50)
                        .position(x: 50, y: 50)
                }.frame(width: 100, height: 100)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
