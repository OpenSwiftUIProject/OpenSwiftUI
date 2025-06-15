//
//  ModifiedColorUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ModifiedColorUITests {
    func opacity() {
        openSwiftUIAssertSnapshot(
            of: Color.red.opacity(0.3)
        )
    }

    @Test
    func multipleOpacityLayers() {
        openSwiftUIAssertSnapshot(
            of: Color.red.opacity(0.6).opacity(0.5)
        )
    }
}
