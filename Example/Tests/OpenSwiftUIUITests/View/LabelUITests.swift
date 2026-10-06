//
//  LabelUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct LabelUITests {
    @Test
    func builtInStyles() {
        openSwiftUIAssertSnapshot(of: LabelStyleExample())
    }
}
