//
//  TestHost.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

package import Foundation

package protocol TestHost: _BenchmarkHost {
    func setTestSize(_ size: CGSize)

    func setTestSafeAreaInsets(_ insets: EdgeInsets)

    // func sendTestEvents(_ events: [EventID: any EventType])

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

    var hasActivePresentation: Bool { get }

    func dismissActivePresentations()

    // var attributeCountInfo: AttributeCountTestInfo { get }
}

extension TestHost {
    package var hasActivePresentation: Bool { false }

    package func dismissActivePresentations() {}
}

extension TestHost {
    package func testIntentsChanged(before: TestIntents, after: TestIntents) {}
}
