//
//  TestHost.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import Foundation

// MARK: - TestHost [6.4.41]

package protocol TestHost: _BenchmarkHost {
    func setTestSize(_ size: CGSize)

    func setTestSafeAreaInsets(_ insets: EdgeInsets)

    var testSize: CGSize { get }

    func sendTestEvents(_ events: [EventID: any EventType])

    func resetTestEvents()

    var environmentOverride: EnvironmentValues? { get set }

    var viewCacheIsEmpty: Bool { get }

    var isHiddenForReuse: Bool { get set }

    func forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void)

    func forEachDescendantHost(body: (any TestHost) -> Void)

    func renderForTest(interval: Double)

    func testIntentsChanged(before: TestIntents, after: TestIntents)

    func invalidateProperties(_ props: ViewRendererHostProperties, mayDeferUpdate: Bool)

    var accessibilityEnabled: Bool { get set }

    var attributeCountInfo: AttributeCountTestInfo { get }
}

extension TestHost {
    package func testIntentsChanged(before: TestIntents, after: TestIntents) {}
}

extension CGSize {
    package static var deviceSize: CGSize {
        CGSize(
            width: Double.greatestFiniteMagnitude,
            height: Double.greatestFiniteMagnitude
        )
    }
}
