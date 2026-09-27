//
//  GroupUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct GroupUITests {
    @Test
    func groupColor() {
        struct ContentView: View {
            var body: some View {
                Group {
                    Color.red
                    Group {
                        Color.blue
                        Color.green
                    }
                }.frame(width: 100, height: 100)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
