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

    @Test("Verify text background height is normal")
    func textHeight() {
        openSwiftUIAssertSnapshot(of: TextBackgroundHeightExample())
    }

    @Test
    func orphanAndPushOut() {
        openSwiftUIAssertSnapshot(of: TextOrphanAndPushOutExample())
    }
}
