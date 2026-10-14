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
            drawHierarchyInKeyWindow: true,
            size: effect == .rotation3D ? CGSize(width: 300, height: 300) : defaultSize,
            named: effect.rawValue
        )
    }
}
