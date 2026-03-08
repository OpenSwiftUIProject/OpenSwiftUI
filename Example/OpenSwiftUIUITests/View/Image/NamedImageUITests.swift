//
//  NamedImageUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct NamedImageUITests {
    @Test
    func decorativeLogo() {
        openSwiftUIAssertSnapshot(of: NamedImageDecorativeExample())
    }
}
