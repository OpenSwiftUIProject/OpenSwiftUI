//
//  DividerUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct DividerUITests {

    // MARK: - Basic Divider in HVStack

    @Test
    func dividerWithColorScheme() {
        struct ContentView: View {
            var body: some View {
                HStack {
                    VStack {
                        VStack {
                            Color.primary
                            Divider()
                            Color.primary
                        }
                        .dynamicTypeSize(.large)
                        .colorScheme(.light)
                        VStack {
                            Color.primary
                            Divider()
                            Color.primary
                        }
                        .dynamicTypeSize(.large)
                        .colorScheme(.dark)
                    }
                    Divider()
                        .dynamicTypeSize(.large)
                        .colorScheme(.light)
                    Divider()
                        .dynamicTypeSize(.accessibility1)
                        .colorScheme(.dark)
                    VStack {
                        VStack {
                            Color.primary
                            Divider()
                            Color.primary
                        }
                        .dynamicTypeSize(.accessibility1)
                        .colorScheme(.light)
                        VStack {
                            Color.primary
                            Divider()
                            Color.primary
                        }
                        .dynamicTypeSize(.accessibility1)
                        .colorScheme(.dark)
                    }
                }
                .background(Color.red)
                .frame(width: 200, height: 200)
            }
        }
        #if os(iOS)
        openSwiftUIAssertSnapshot(of: ContentView())
        #else
        withKnownIssue("Path/Shape is not implemented") {
            openSwiftUIAssertSnapshot(of: ContentView())
        }
        #endif
    }
}
