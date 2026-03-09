//
//  NamedColorUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct NamedColorUITests {
    @Test
    func namedColor() {
        openSwiftUIAssertSnapshot(of: NamedColorExample())
    }
}
