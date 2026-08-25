//
//  ProgressViewUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ProgressViewUITests {
    @Test
    func valueBasedProgress() {
        openSwiftUIAssertSnapshot(of: ProgressViewExample())
    }

    @Test
    func indeterminateInitializers() {
        openSwiftUIAssertSnapshot(of: IndeterminateProgressViewExample())
    }

    @Test(.disabled("ResolvableTextSegmentAttribute is not implemented yet"))
    func defaultDateProgressLabelInitializers() {
        openSwiftUIAssertSnapshot(of: DefaultDateProgressLabelExample())
    }

    @Test(
        .disabled(if: attributeGraphVendor == .compute, "Temporarily disabled for IAG snapshot crash")
    )
    func foundationProgress() {
        openSwiftUIAssertSnapshot(of: FoundationProgressViewExample())
    }
}
