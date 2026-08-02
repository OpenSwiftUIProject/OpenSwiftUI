//
//  PlatformEnvironment.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: C3D4386B65791FA87065FFB821A7CBCF (SwiftUI)

import COpenSwiftUI
import OpenSwiftUICore
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

        #if os(macOS)
        // accessibilityTextAttributeResolver =
        // fallbackFontProvider =
        systemAccentValueProvider = MacSystemAccentValueProvider.self
        #endif

        // resolvedTextProvider = OpenSwiftUIResolvedTextProvider.self
        hasSystemOpenURLAction = true

        #if os(iOS) || os(visionOS)
        // bridgedEnvironmentResolver = UITraitBridgedEnvironmentResolver.self
        #if OPENSWIFTUI_LINK_COREUI
        let idiom = traitCollection?.userInterfaceIdiom ?? UIDevice.current.userInterfaceIdiom
        cuiAssetIdiom = _CUIIdiomForIdiom(idiom).rawValue
        cuiAssetSubtype = Int(_CUISubtypeForIdiom(idiom).rawValue)
        cuiAssetMatchTypes = CatalogAssetMatchType.defaultValue(idiom: _CUIIdiomForIdiom(idiom).rawValue)
        #endif
        #endif
    }
}
