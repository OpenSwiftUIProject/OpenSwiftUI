//
//  CompositingGroupEffectUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct CompositingGroupEffectUITests {
    @Test
    func textOpacity() {
        openSwiftUIAssertSnapshot(
            of: CompositingGroupTextExample(),
            drawHierarchyInKeyWindow: true,
            size: CGSize(width: 400, height: 240)
        )
    }

    @Test
    func overlappingCirclesOpacity() {
        openSwiftUIAssertSnapshot(
            of: CompositingGroupCirclesExample(),
            drawHierarchyInKeyWindow: true
        )
    }
}
