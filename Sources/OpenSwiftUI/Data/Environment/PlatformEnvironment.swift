//
//  PlatformEnvironment.swift
//  OpenSwiftUI
//
//  Status: WIP
//  ID: C3D4386B65791FA87065FFB821A7CBCF (SwiftUI)

import OpenSwiftUI_SPI
import OpenSwiftUICore
#if os(iOS)
import UIKit
typealias TraitCollection = UITraitCollection
#elseif os(macOS)
import AppKit
typealias TraitCollection = Void
#else
typealias TraitCollection = Void
#endif

// MARK: - Environment + Platform [6.4.41]

extension EnvironmentValues {
    static let configuredForPlatform: EnvironmentValues = {
        var env = EnvironmentValues(PropertyList())
        env._configureForPlatform(traitCollection: nil)
        return env
    }()

    mutating func configureForPlatform(traitCollection: TraitCollection?) {
        guard let traitCollection else {
            plist.set(Self.configuredForPlatform.plist)
            return
        }
        if plist.isIdentical(to: Self.configuredForPlatform.plist) {
            plist = .init()
        }
        _configureForPlatform(traitCollection: traitCollection)
    }

    private mutating func _configureForPlatform(traitCollection: TraitCollection?) {
        // defaultAccentColorProvider = OpenSwiftUIDefaultAccentColorProvider.self
        #if OPENSWIFTUI_LINK_COREUI
        cuiNamedColorProvider = KitCoreUINamedColorProvider.self
        #endif

        #if os(macOS)
        // accessibilityTextAttributeResolver =
        // fallbackFontProvider =
        // systemAccentValueProvider =
        #endif

        // resolvedTextProvider = OpenSwiftUIResolvedTextProvider.self
        // hasSystemOpenURLAction = true

        #if os(iOS)
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
