//
//  GroupBoxUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct GroupBoxUITests {
    @Test(arguments: [false, true])
    func agreement(userAgreed: Bool) {
        openSwiftUIAssertSnapshot(
            of: GroupBoxExample(userAgreed: userAgreed),
            size: .init(width: 340, height: 180),
            named: userAgreed ? "agreed" : "pending"
        )
    }

    @Test
    func customStyle() {
        openSwiftUIAssertSnapshot(
            of: GroupBoxStyleExample(),
            size: .init(width: 280, height: 160)
        )
    }
}
