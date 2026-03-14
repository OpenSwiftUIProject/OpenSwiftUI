//
//  ImageConversionsUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ImageConversionsUITests {
    @Test("Test Image(platformImage:) with named image")
    func platformImageNamed() {
        openSwiftUIAssertSnapshot(of: ImageConversionsExample())
    }

    @Test("Test Image(platformImage:) with system image")
    func platformImageSystem() {
        openSwiftUIAssertSnapshot(of: ImageConversionsSystemImageExample())
    }
}
