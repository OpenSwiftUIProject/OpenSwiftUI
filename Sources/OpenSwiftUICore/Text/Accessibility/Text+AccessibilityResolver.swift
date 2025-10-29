//
//  Text+AccessibilityResolver.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

package import Foundation

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
    package var accessibilityTextAttributeResolver: (any AccessibilityTextAttributeResolver)? {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }
}

extension NSAttributedString {
    convenience package init(axAttributedString: String) {
        _openSwiftUIUnimplementedFailure()
    }
}

extension NSAttributedString.Key {
    package static var coreAXForegroundColor: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXFontName: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXFontSize: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXFontFamily: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXStrikethrough: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXUnderline: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXAlignment: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXAttachment: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXLink: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXTextHeadingLevel: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXSpeechPitch: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXSpeechPunctuation: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXSpeechSpellOut: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXSpeechIPANotation: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXTextualContext: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXSpeechAnnouncementPriority: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static var coreAXSpeechLanguage: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }

    package static let coreAXLabel: NSAttributedString.Key = .init("")

    package static var coreAXDurationTimeMMSS: NSAttributedString.Key {
        _openSwiftUIUnimplementedFailure()
    }
}

extension NSAttributedString.Key {
    package var isAccessibilityAttribute: Bool {
        _openSwiftUIUnimplementedFailure()
    }
}
