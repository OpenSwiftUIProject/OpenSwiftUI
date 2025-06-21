//
//  FixedSizeLayoutUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct FixedSizeLayoutUITests {
    @Test
    func colorFixedSize() {
        struct ContentView: View {
            var body: some View {
                ZStack {
                    Color.red.opacity(0.5)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(width: 100, height: 100)
                    Color.green.opacity(0.5)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 100, height: 100)
                    Color.blue.opacity(0.5)
                        .fixedSize(horizontal: false, vertical: false)
                        .frame(width: 100, height: 100)
                }
            }
        }
        openSwiftUIAssertSnapshot(
            of: ContentView(),
            // FIXME: Workaround #340
            perceptualPrecision: 0.99
        )
    }
}
