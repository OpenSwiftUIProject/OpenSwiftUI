//
//  GeometryReaderUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct GeometryReaderUITests {
    @Test(.bug("https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/474"))
    func centerView() {
        openSwiftUIAssertSnapshot(of: GeometryReaderExample())
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
