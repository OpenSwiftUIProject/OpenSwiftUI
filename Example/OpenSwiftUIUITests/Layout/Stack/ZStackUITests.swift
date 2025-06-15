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

    // TODO: layoutPriority
}
