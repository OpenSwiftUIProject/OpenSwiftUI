//
//  LineLimitsUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct LineLimitsUITests {
    @Test
    func lineLimit() {
        openSwiftUIAssertSnapshot(of: LineLimitExample())
    }

    @Test
    func lineLimitReservesSpace() {
        openSwiftUIAssertSnapshot(of: LineLimitReservesSpaceExample())
    }
}
