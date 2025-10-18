//
//  ZIndexCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Foundation
import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ZStackIndexUITests {
    @Test
    func rotateOverlap() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    // TODO: Path & Shape is not implemented yet.
                    Color.yellow
//                    Rectangle()
//                        .fill(Color.yellow)
                        .frame(width: 100, height: 100, alignment: .center)
                        .zIndex(1) // Top layer.
                    Color.red
//                    Rectangle()
//                        .fill(Color.red)
                        .frame(width: 100, height: 100, alignment: .center)
                        .rotationEffect(.degrees(45))
                        // Here a zIndex of 0 is the default making
                        // this the bottom layer.
                }
            }
        }
        openSwiftUIAssertSnapshot(
            of: ContentView(),
            size: CGSize(width: 200, height: 200)
        )
    }
}
