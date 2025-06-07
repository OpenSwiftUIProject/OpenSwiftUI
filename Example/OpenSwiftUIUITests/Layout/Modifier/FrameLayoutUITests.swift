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

#if os(iOS)
import UIKit

#if !OPENSWIFTUI
@available(iOS 15, *)
#endif
@MainActor
@Suite(.snapshots(record: .never, diffTool: .ksdiff))
struct FrameLayoutUITests {
    @Test
    func noFrame() {
        struct ContentView: View {
            var body: some View {
                Color.red.frame()
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func frameSize() {
        struct ContentView: View {
            var body: some View {
                Color.red.frame(width: 10, height: 10)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
#endif
