//
//  HostingViewUITests.swift
//  OpenSwiftUIUITests

import Testing
import TestingHost
import SnapshotTesting

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct HostingViewUITests {
    var content: some View {
        Color.red
    }

    @Test
    func basicView() {
        let hostingView = PlatformHostingView(rootView: content)
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        let vc = NSViewController()
        vc.view = hostingView
        #elseif canImport(UIKit)
        let vc = UIViewController()
        vc.view = hostingView
        #endif
        openSwiftUIControllerAssertSnapshot(
            of: vc,
            as: .image(drawHierarchyInKeyWindow: false, size: defaultSize)
        )
    }
}
