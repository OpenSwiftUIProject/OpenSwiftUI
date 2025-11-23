//
//  DividerUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct DividerUITests {

    // MARK: - Basic Spacer in HStack

    @Test("TODO: Fix colorScheme issue")
    func dividerWithColorScheme() {
        struct ContentView: View {
            var body: some View {
                HStack {
                    VStack {
                        VStack {
                            Color.red
                            Divider()
                            Color.blue
                        }
                        HStack {
                            Color.red
                            Divider()
                            Color.blue
                        }
                    }.colorScheme(.light)
                    VStack {
                        HStack {
                            Color.red
                            Divider()
                            Color.blue
                        }
                        VStack {
                            Color.red
                            Divider()
                            Color.blue
                        }
                    }.colorScheme(.dark)
                }
                .background(Color.green)
            }
        }
        withKnownIssue("Path/Shape is not implemented") {
            openSwiftUIAssertSnapshot(of: ContentView())
        }
    }
}
