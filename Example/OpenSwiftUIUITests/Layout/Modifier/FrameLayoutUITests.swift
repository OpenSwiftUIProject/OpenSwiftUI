//
//  FrameLayoutUITests.swift
//  OpenSwiftUIUITests

import XCTest
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
final class FrameLayoutUITests: XCTestCase {
    func testNoFrame() {
        struct ContentView: View {
            var body: some View {
                Color.red.frame()
            }
        }
        withSnapshotTesting(diffTool: .ksdiff) {
            assertSnapshot(
                of: UIHostingController(rootView: ContentView()),
                as: .image(on: .iPhone13Pro),
                record: shouldRecord
            )
        }
    }

    func testFrameSize() {
        struct ContentView: View {
            var body: some View {
                Color.red.frame(width: 10, height: 10)
            }
        }
        withSnapshotTesting(diffTool: .ksdiff) {
            assertSnapshot(
                of: UIHostingController(rootView: ContentView()),
                as: .image(on: .iPhone13Pro),
                record: shouldRecord
            )
        }
    }
}
#endif
