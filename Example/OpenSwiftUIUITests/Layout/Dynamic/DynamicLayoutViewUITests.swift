//
//  DynamicLayoutViewUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct DynamicLayoutViewUITests {
    @Test
    func dynamicLayout() {
        struct ContentView: View {
            @State var show = false
            var body: some View {
                VStack {
                    Color.red
                        .task { show = true }
                    if show {
                        Color.blue
                    }
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
