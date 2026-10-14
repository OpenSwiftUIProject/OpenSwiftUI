//
//  ProjectionEffectUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ProjectionEffectUITests {
    @Test
    func projectiveTransform() {
        openSwiftUIAssertSnapshot(
            of: ProjectionEffectExample(),
            drawHierarchyInKeyWindow: true
        )
    }
}
