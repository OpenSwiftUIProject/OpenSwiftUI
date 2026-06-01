//
//  TextFormatStyleUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct TextFormatStyleUITests {
    @Test(.disabled("Text layout is not ready"))
    func dateFormatStyleExample() {
        openSwiftUIAssertSnapshot(of: TextFormatStyleExample())
    }
}
