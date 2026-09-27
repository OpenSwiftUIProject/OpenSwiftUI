//
//  TextUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct TextUITests {
    @Test
    func foregroundColor() {
        openSwiftUIAssertSnapshot(of: TextForegroundExample())
    }

    @Test
    func dateFormatStyleExample() {
        openSwiftUIAssertSnapshot(of: TextFormatStyleExample())
    }

    @Test
    func systemFormatStyleExample() {
        openSwiftUIAssertSnapshot(
            of: TextSystemFormatStyleExample(),
            size: CGSize(width: 320, height: 260)
        )
    }

    @Test("Verify text background height is normal")
    func textHeight() {
        openSwiftUIAssertSnapshot(of: TextBackgroundHeightExample())
    }

    @Test
    func orphanAndPushOut() {
        openSwiftUIAssertSnapshot(of: TextOrphanAndPushOutExample())
    }
}
