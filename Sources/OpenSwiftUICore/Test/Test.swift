//
//  Test.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

public protocol _Test {
    func setUpTest()
    func tearDownTest()
    func tearDownTestWithError() throws
}

extension _Test {
    public func setUpTest() {}
    public func tearDownTest() {}
    public func tearDownTestWithError() throws {}
}

package struct TestIntents: OptionSet {
    package let rawValue: UInt64

    package init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    package static let ignoreGeometry: TestIntents = .init(rawValue: 1 << 0)

    package static let ignoreTinting: TestIntents = .init(rawValue: 1 << 1)

    package static let includeColorScheme: TestIntents = .init(rawValue: 1 << 2)

    package static let ignoreCornerRadius: TestIntents = .init(rawValue: 1 << 3)

    package static let lazyLoadMenus: TestIntents = .init(rawValue: 1 << 4)

    package static let includeChildWindows: TestIntents = .init(rawValue: 1 << 5)

    package static let includeTransparency: TestIntents = .init(rawValue: 1 << 6)

    package static let includeWindowConstraints: TestIntents = .init(rawValue: 1 << 7)

    package static let includeSplitViewItemState: TestIntents = .init(rawValue: 1 << 8)

    package static let includeListSeparators: TestIntents = .init(rawValue: 1 << 9)

    package static let includeTableRowViews: TestIntents = .init(rawValue: 1 << 10)

    package static let includeStatusBar: TestIntents = .init(rawValue: 1 << 11)

    package static let includeTruncation: TestIntents = .init(rawValue: 1 << 12)

    package static let includeExtendedContents: TestIntents = .init(rawValue: 1 << 13)

    package static let includeWindowStyleMask: TestIntents = .init(rawValue: 1 << 14)

    package static let includeBridgeMetrics: TestIntents = .init(rawValue: 1 << 15)

    package static let ignoreDisabled: TestIntents = .init(rawValue: 1 << 16)

    package static let includeListBackground: TestIntents = .init(rawValue: 1 << 17)

    package static let includeExtendedGradients: TestIntents = .init(rawValue: 1 << 18)

    package static let ignoreNavigationBarDisplayMode: TestIntents = .init(rawValue: 1 << 19)

    package static let ignoreOpacity: TestIntents = .init(rawValue: 1 << 20)

    package static let useFocusNavigation: TestIntents = .init(rawValue: 1 << 21)

    package static let includeScrollEnvironment: TestIntents = .init(rawValue: 1 << 22)

    package static let includeFocusableBorder: TestIntents = .init(rawValue: 1 << 23)

    package static let includeListTypeSelect: TestIntents = .init(rawValue: 1 << 24)

    package static let includeSystemMenuItemDetails: TestIntents = .init(rawValue: 1 << 25)

    package static let includePlaceholderStyling: TestIntents = .init(rawValue: 1 << 26)

    package static let isolateSheetSize: TestIntents = .init(rawValue: 1 << 27)

    package static let ignoreStackContent: TestIntents = .init(rawValue: 1 << 28)

    package static let includePresentationChildrenGeometry: TestIntents = .init(rawValue: 1 << 29)

    package static let includePresentationOptions: TestIntents = .init(rawValue: 1 << 30)

    package static let ignoreHoverEffects: TestIntents = .init(rawValue: 1 << 31)

    package static let ignoreToolbarContents: TestIntents = .init(rawValue: 1 << 32)

    package static let includeSemanticContext: TestIntents = .init(rawValue: 1 << 33)

    package static let includeTableHeaderStyling: TestIntents = .init(rawValue: 1 << 36)

    package static let includeBaselines: TestIntents = .init(rawValue: 1 << 37)

    package static let includePageControlGeometry: TestIntents = .init(rawValue: 1 << 38)

    package static let includeHostingViewCornerRadius: TestIntents = .init(rawValue: 1 << 49)

    package static let includeSheetPresentationProperties: TestIntents = .init(rawValue: 1 << 50)

    package static let ignoreCompositingFilters: TestIntents = .init(rawValue: 1 << 51)

    package static let includeToolbarLayoutMargins: TestIntents = .init(rawValue: 1 << 52)

    package static let includeContinuousCorners: TestIntents = .init(rawValue: 1 << 54)

    package static let includePopoverArrowDirection: TestIntents = .init(rawValue: 1 << 55)

    package static let includePopoverBackground: TestIntents = .init(rawValue: 1 << 56)

    package static let validateMenuItemActions: TestIntents = .init(rawValue: 1 << 58)

    package static let ignorePlatformSpecificStyling: TestIntents = [.ignoreGeometry, .ignoreCornerRadius, .ignoreOpacity, .ignoreCompositingFilters]
}

package struct PlatformViewTestProperties: OptionSet {
    package let rawValue: UInt64

    package init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    package static let remoteEffectAuxiliaryView: PlatformViewTestProperties = .init(rawValue: 1 << 0)
}

#if canImport(QuartzCore)
package import QuartzCore

extension CALayer {
    package var testProperties: PlatformViewTestProperties {
        get { PlatformViewTestProperties(rawValue: openSwiftUI_viewTestProperties) }
        set { openSwiftUI_viewTestProperties = newValue.rawValue }
    }
}
#endif
