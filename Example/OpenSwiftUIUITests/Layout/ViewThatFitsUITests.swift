//
//  ViewThatFitsUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ViewThatFitsUITests {
    @Test
    func uploadProgressAlternatives() {
        openSwiftUIAssertSnapshot(of: ViewThatFitsExample())
    }
}
