//
//  ZStackUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ZStackUITests {
    @Test(
        arguments: [
            (Alignment.center, "center"),
            (Alignment.top, "top"),
            (Alignment.bottom, "bottom"),
            (Alignment.leading, "leading"),
            (Alignment.trailing, "trailing"),
            (Alignment.topLeading, "topLeading"),
            (Alignment.topTrailing, "topTrailing"),
            (Alignment.bottomLeading, "bottomLeading"),
            (Alignment.bottomTrailing, "bottomTrailing"),
        ]
    )
    func alignment(_ alignment: Alignment, name: String) {
        struct ContentView: View {
            let alignment: Alignment

            var body: some View {
                ZStack(alignment: alignment) {
                    Color.red.frame(width: 60, height: 60)
                    Color.blue.frame(width: 20, height: 20)
                }
            }
        }
        openSwiftUIAssertSnapshot(
            of: ContentView(
                alignment: alignment
            ),
            testName: "alignment_\(name)"
        )
    }

    @Test
    func layoutPriority() {
        struct ContentView: View {
            var body: some View {
                ZStack(alignment: .leading) {
                    Color.blue
                        .opacity(0.5)
                        .frame(width: 100, height: 100)
                        .layoutPriority(-0.1)
                    Color.red
                        .opacity(0.5)
                        .frame(width: 60, height: 60)
                    Color.green
                        .frame(width: 40, height: 40)
                        .layoutPriority(1)
                }
                .overlay {
                    Color.black
                        .frame(width: 20, height: 20)
                }
            }
        }
        openSwiftUIAssertSnapshot(
            of: ContentView()
        )
    }

    @Test
    func overlayAndBackground() {
        struct ContentView: View {
            var body: some View {
                ZStack(alignment: .leading) {
                    Color.red
                        .opacity(0.5)
                        .frame(width: 200, height: 200)
                }
                .overlay(alignment: .topLeading) {
                    Color.green.opacity(0.5)
                        .frame(width: 100, height: 100)
                }
                .background(alignment: .bottomTrailing) {
                    Color.blue.opacity(0.5)
                        .frame(width: 100, height: 100)
                }
            }
        }
        openSwiftUIAssertSnapshot(
            of: ContentView()
        )
    }
}
