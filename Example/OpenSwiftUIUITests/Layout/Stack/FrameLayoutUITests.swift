//
//  FrameLayoutUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct FrameLayoutUITests {
    @Test
    func noFrame() {
        struct ContentView: View {
            var body: some View {
                Color.red.frame()
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), size: CGSize(width: 200, height: 200))
    }

    @Test
    func frameSize() {
        struct ContentView: View {
            var body: some View {
                Color.red.frame(width: 10, height: 10)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), size: CGSize(width: 200, height: 200))
    }
}
