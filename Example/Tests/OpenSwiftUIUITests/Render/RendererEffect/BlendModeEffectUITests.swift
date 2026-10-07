//
//  BlendModeEffectUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct BlendModeEffectUITests {
    @Test
    func colorBurn() {
        openSwiftUIAssertSnapshot(
            of: BlendModeColorBurnExample(),
            drawHierarchyInKeyWindow: true
        )
    }
}
