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

    @Test(.tags(.org_openswiftuiproject_openswiftui.localization))
    func indeterminateInitializers() {
        openSwiftUIAssertSnapshot(
            of: IndeterminateProgressViewExample(),
            size: CGSize(width: 400, height: 400)
        )
    }

    @Test(.disabled("TextLayoutManager is not implemented yet"))
    func defaultDateProgressLabelInitializers() {
        openSwiftUIAssertSnapshot(of: DefaultDateProgressLabelExample())
    }

    @Test
    func foundationProgress() {
        #if os(iOS)
        // FIXME: The SwiftUI reference image is flaky on CI while the Foundation progress label settles.
        withKnownIssue("The SwiftUI reference image is flaky on CI", isIntermittent: true) {
            openSwiftUIAssertSnapshot(of: FoundationProgressViewExample())
        }
        #else
        openSwiftUIAssertSnapshot(of: FoundationProgressViewExample())
        #endif
    }
}
