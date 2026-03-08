//
//  NamedImageUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct NamedImageUITests {
    @Test
    func decorativeLogo() {
        openSwiftUIAssertSnapshot(of: NamedImageDecorativeExample())
    }

    @Test
    func renderingModeOriginal() {
        openSwiftUIAssertSnapshot(of: NamedImageRenderingModeOriginalExample())
    }

    @Test
    func renderingModeTemplate() {
        openSwiftUIAssertSnapshot(of: NamedImageRenderingModeTemplateExample())
    }
}
