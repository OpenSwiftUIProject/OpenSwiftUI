//
//  PlatformEnvironment.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: C3D4386B65791FA87065FFB821A7CBCF (SwiftUI)

import COpenSwiftUI
import OpenSwiftUICore
import UIFoundation_Private
#if os(iOS) || os(visionOS)
import UIKit
typealias TraitCollection = UITraitCollection
#elseif os(macOS)
import AppKit
typealias TraitCollection = Void
#else
typealias TraitCollection = Void
#endif

// MARK: - Environment + Platform

extension EnvironmentValues {
    static let configuredForPlatform: EnvironmentValues = {
        var env = EnvironmentValues(PropertyList())
        env._configureForPlatform(traitCollection: nil)
        return env
    }()

    mutating func configureForPlatform(traitCollection: TraitCollection?) {
        if plist.isIdentical(to: Self.configuredForPlatform.plist) {
            guard traitCollection != nil else {
                return
            }
            plist = .init()
        }
        if plist.isEmpty, traitCollection == nil {
            plist = Self.configuredForPlatform.plist
        } else {
            _configureForPlatform(traitCollection: traitCollection)
        }
    }

    private mutating func _configureForPlatform(traitCollection: TraitCollection?) {
        defaultAccentColorProvider = OpenSwiftUIDefaultAccentColorProvider.self
        #if OPENSWIFTUI_LINK_COREUI
        cuiNamedColorProvider = KitCoreUINamedColorProvider.self
        #endif
        accessibilityTextAttributeResolver = OpenSwiftUIAccessibilityTextResolver()
        #if os(macOS)
        fallbackFontProvider = OpenSwiftUIFallbackFontProvider()
        systemAccentValueProvider = MacSystemAccentValueProvider.self
        #endif
        resolvedTextProvider = OpenSwiftUIResolvedTextProvider.self
        hasSystemOpenURLAction = true
        #if os(iOS) || os(visionOS)
        bridgedEnvironmentResolver = UITraitBridgedEnvironmentResolver.self
        #if OPENSWIFTUI_LINK_COREUI
        let idiom = traitCollection?.userInterfaceIdiom ?? UIDevice.current.userInterfaceIdiom
        cuiAssetIdiom = _CUIIdiomForIdiom(idiom).rawValue
        cuiAssetSubtype = Int(_CUISubtypeForIdiom(idiom).rawValue)
        cuiAssetMatchTypes = CatalogAssetMatchType.defaultValue(idiom: _CUIIdiomForIdiom(idiom).rawValue)
        #endif
        #endif
    }
}

// FIXME
import Foundation

struct OpenSwiftUIAccessibilityTextResolver: AccessibilityTextAttributeResolver {
    func resolveDefaultAttributes(
        _ attributes: inout [NSAttributedString.Key: Any]
    ) {
        _openSwiftUIUnimplementedWarning()
    }

    func resolveTextStyleAttributes(
        _ attributes: inout [NSAttributedString.Key: Any],
        textStyle: Text.Style,
        environment: EnvironmentValues
    ) {
        _openSwiftUIUnimplementedWarning()
    }

    func resolveAccessibilitySpeechAttributes(
        into attributes: inout [NSAttributedString.Key: Any],
        speechAttr: AccessibilitySpeechAttributes,
        environment: EnvironmentValues,
        includeDefaultAttributes: Bool
    ) {
        _openSwiftUIUnimplementedWarning()
    }
}

struct OpenSwiftUIResolvedTextProvider: ResolvedTextProvider {
    static func defaultLinkColor(
        for environment: EnvironmentValues
    ) -> Color {
        .accentColor
    }

    static func updateImageTextAttachment(
        in attachment: NSTextAttachment,
        image: Image.Resolved
    ) {
        _openSwiftUIUnimplementedWarning()
    }

    static func updateWidgetTextAttachment(
        _ attachment: NSTextAttachment,
        namedImage: Image.NamedResolved
    ) {
        _openSwiftUIUnimplementedWarning()
    }
}

#if os(macOS)
struct OpenSwiftUIFallbackFontProvider: FallbackFontProvider {
    func makeFont(in env: EnvironmentValues) -> Font {
        Font._system(controlSize: env.controlSize)
    }
}

extension Font {
    static func _system(controlSize: ControlSize) -> Font {
        let size = NSFont.systemFontSize(for: NSControl.ControlSize(controlSize))
        return Font.system(size: size)
    }
}

// ID: F50FEC7433F4F726B3FD7F77709599DA
private struct TouchbarFallbackFontProvider: FallbackFontProvider {
    func makeFont(in env: EnvironmentValues) -> Font {
        Font.system(size: 15.0)
    }
}
#endif
