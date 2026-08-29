//
//  CAHostingLayerUITests.swift
//  OpenSwiftUIUITests

import Testing
@testable import TestingHost
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct CAHostingLayerUITests {
    #if !OPENSWIFTUI
    @available(iOS 18.0, macOS 15.0, *)
    #endif
    @Test
    func basicLayer() {
        openSwiftUIAssertSnapshot(
            of: CAHostingLayerExample(content: Color.red),
            as: .image(drawHierarchyInKeyWindow: false, size: defaultSize)
        )
    }
}
