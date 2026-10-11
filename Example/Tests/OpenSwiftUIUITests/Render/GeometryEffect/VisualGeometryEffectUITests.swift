//
//  VisualGeometryEffectUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct VisualGeometryEffectUITests {
    @Test(arguments: VisualGeometryEffectExample.Effect.allCases)
    func geometryEffects(_ effect: VisualGeometryEffectExample.Effect) {
        openSwiftUIAssertSnapshot(
            of: VisualGeometryEffectExample(effect: effect),
            named: effect.rawValue
        )
    }
}
