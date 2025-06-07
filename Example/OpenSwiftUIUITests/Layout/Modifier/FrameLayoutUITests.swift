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
    func testFrameSize() {
        struct ContentView: View {
            var body: some View {
                Color.red.frame(width: 10, height: 10)
            }
        }
        assertSnapshot(
            of: UIHostingController(rootView: ContentView()),
            as: .image,
            record: shouldRecord
        )
    }
}
#endif
