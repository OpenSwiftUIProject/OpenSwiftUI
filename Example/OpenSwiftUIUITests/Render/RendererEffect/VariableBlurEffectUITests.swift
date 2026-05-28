//
//  VariableBlurEffectUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct VariableBlurEffectUITests {
    @Test
    func variableBlurImageMask() {
        openSwiftUIAssertSnapshot(
            of: VariableBlurEffectExample(),
            drawHierarchyInKeyWindow: true
        )
    }
}
