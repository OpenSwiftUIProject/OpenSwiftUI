//
//  TransformEffectUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct TransformEffectUITests {
    @Test
    func shearAndTranslation() {
        openSwiftUIAssertSnapshot(
            of: TransformEffectExample(),
            rasterizeOnMacOS: true
        )
    }
}
