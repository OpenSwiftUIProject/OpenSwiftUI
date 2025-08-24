//
//  GeometryReaderUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct GeometryReaderUITests {
    @Test
    func centerView() {
        struct ContentView: View {
            var body: some View {
                GeometryReader { proxy in
                    Color.blue
                        .frame(
                            width: proxy.size.width / 2,
                            height: proxy.size.height / 2,
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.yellow.opacity(0.3))
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func overlapView() {
        struct ContentView: View {
            var body: some View {
                GeometryReader { geometry in
                    Color.blue
                        .frame(
                            width: geometry.size.width / 2,
                            height: geometry.size.height / 2
                        )
                    Color.red
                        .frame(
                            width: geometry.size.width / 3,
                            height: geometry.size.height / 3
                        )
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
