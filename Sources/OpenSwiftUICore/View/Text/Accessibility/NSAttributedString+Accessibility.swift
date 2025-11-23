//
//  NSAttributedString+Accessibility.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 2BDB458C6E5F105189088F0894A913CC (SwiftUICore)

package import Foundation

// MARK: - Accessibility + Text resolve [WIP]

extension AccessibilityCore {
    package static func textResolvesToEmpty(_ text: Text, in environment: EnvironmentValues) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package static func textsResolveToEmpty(_ texts: [Text], in environment: EnvironmentValues) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package static func textResolvedToPlainText(
        _ text: Text,
        in environment: EnvironmentValues,
        updateResolvableAttributes: Bool = false,
        idiom: AnyInterfaceIdiom? = nil
    ) -> String {
        _openSwiftUIUnimplementedFailure()
    }

    package static func textsResolvedToPlainText(
        _ texts: [Text],
        in environment: EnvironmentValues,
        updateResolvableAttributes: Bool = false,
        idiom: AnyInterfaceIdiom? = nil,
        separator: String = ", "
    ) -> String? {
        _openSwiftUIUnimplementedFailure()
    }

    package static func textResolvedToAttributedText(
        _ text: Text,
        in environment: EnvironmentValues,
        includeResolvableAttributes: Bool = false,
        includeDefaultAttributes: Bool = true,
        updateResolvableAttributes: Bool = true,
        idiom: AnyInterfaceIdiom? = nil
    ) -> NSAttributedString? {
        _openSwiftUIUnimplementedFailure()
    }

    @discardableResult
    package static func resolveAttributedTextAttributes(
        in string: inout NSAttributedString,
        environment: EnvironmentValues,
        includeResolvableAttributes: Bool = false
    ) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package static func resolveAttributedTextAttributes(
        _ attributes: inout [NSAttributedString.Key: Any],
        environment: EnvironmentValues
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    package static func resolveAccessibilitySpeechAttributes(
        into attributes: inout [NSAttributedString.Key: Any],
        speechAttr: AccessibilitySpeechAttributes,
        environment: EnvironmentValues,
        includeDefaultAttributes: Bool = true
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    package static func textsResolvedToAttributedText(
        _ texts: [Text],
        in environment: EnvironmentValues,
        includeResolvableAttributes: Bool = false,
        includeDefaultAttributes: Bool = true,
        updateResolvableAttributes: Bool = true,
        resolveSuffix: Bool = false,
        idiom: AnyInterfaceIdiom? = nil,
        separator: String = ", "
    ) -> NSAttributedString? {
        _openSwiftUIUnimplementedFailure()
    }
}

extension Text {
    package func accessibilityResolvedText(
        in environment: EnvironmentValues,
        idiom: AnyInterfaceIdiom? = nil
    ) -> AccessibilityText? {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - AccessibilityTextAttributeResolver

package protocol AccessibilityTextAttributeResolver {
    func resolveDefaultAttributes(_: inout [NSAttributedString.Key: Any])

    func resolveTextStyleAttributes(
        _: inout [NSAttributedString.Key: Any],
        textStyle: Text.Style,
        environment: EnvironmentValues
    )

    func resolveAccessibilitySpeechAttributes(
        into attributes: inout [NSAttributedString.Key: Any],
        speechAttr: AccessibilitySpeechAttributes,
        environment: EnvironmentValues,
        includeDefaultAttributes: Bool
    )
}

extension EnvironmentValues {
    private struct AccessibilityTextAttributeResolverKey: EnvironmentKey {
        static let defaultValue: (any AccessibilityTextAttributeResolver)? = nil
    }

    package var accessibilityTextAttributeResolver: (any AccessibilityTextAttributeResolver)? {
        get { self[AccessibilityTextAttributeResolverKey.self] }
        set { self[AccessibilityTextAttributeResolverKey.self] = newValue }
    }
}

// MARK: - NSAttributedString + AX [WIP]

extension NSAttributedString {
    convenience package init(axAttributedString: String) {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - AX AttributedString Keys

extension NSAttributedString.Key {
    package static var coreAXForegroundColor: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilityTokenForegroundColor") : .init("AXForegroundColor")
    }

    package static var coreAXFontName: NSAttributedString.Key {
        .init("UIAccessibilityTokenFontName")
    }

    package static var coreAXFontSize: NSAttributedString.Key {
        .init("UIAccessibilityTokenFontSize")
    }

    package static var coreAXFontFamily: NSAttributedString.Key {
        .init("UIAccessibilityTokenFontFamily")
    }

    package static var coreAXStrikethrough: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilityTokenStrikethrough") : .init("AXStrikethrough")
    }

    package static var coreAXUnderline: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilityTokenUnderline") : .init("AXUnderline")
    }

    package static var coreAXAlignment: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilityTokenParagraphAlignment") : .init("AXATextAlignmentValue")
    }

    package static var coreAXAttachment: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilityTokenAttachment") : .init("AXAttachment")
    }

    package static var coreAXLink: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilityTokenLink") : .init("AXLink")
    }

    package static var coreAXTextHeadingLevel: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilityTextAttributeHeadingLevel") : .init("AXHeadingLevel")
    }

    package static var coreAXSpeechPitch: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilitySpeechAttributePitch") : .init("AXPitch")
    }

    package static var coreAXSpeechPunctuation: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilitySpeechAttributePunctuation") : .init("AXPunctuation")
    }

    package static var coreAXSpeechSpellOut: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilitySpeechAttributeSpellOut") : .init("AXSpellOut")
    }

    package static var coreAXSpeechIPANotation: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilitySpeechAttributeIPANotation") : .init("AXIPANotation")
    }

    package static var coreAXTextualContext: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilityTextAttributeContext") : .init("AXTextualContext")
    }

    package static var coreAXSpeechAnnouncementPriority: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilitySpeechAttributeAnnouncementPriority") : .init("AXAnnouncementPriority")
    }

    package static var coreAXSpeechLanguage: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilitySpeechAttributeLanguage") : .init("AXLanguage")
    }

    package static let coreAXLabel: NSAttributedString.Key = .init("OpenSwiftUI.accessibilityLabel")

    package static var coreAXDurationTimeMMSS: NSAttributedString.Key {
        isUIKitBased() ? .init("UIAccessibilityTokenDurationTimeMMSS") : .init("AXTokenDurationTimeMMSS")
    }
}

extension NSAttributedString.Key {
    package var isAccessibilityAttribute: Bool {
        rawValue.hasPrefix(isUIKitBased() ? "UIAccessibility" : "AX")
    }
}
