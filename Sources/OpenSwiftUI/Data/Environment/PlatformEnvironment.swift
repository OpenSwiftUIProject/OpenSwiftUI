//
//  PlatformEnvironment.swift
//  OpenSwiftUI
//
//  Status: WIP
//  ID: C3D4386B65791FA87065FFB821A7CBCF (SwiftUI)

#if os(iOS)
import OpenSwiftUI_SPI
import OpenSwiftUICore
import UIKit

// MARK: - Environment + Platform [6.4.41]

extension EnvironmentValues {
    static let configuredForPlatform: EnvironmentValues = {
        var env = EnvironmentValues(PropertyList())
        env._configureForPlatform(traitCollection: nil)
        return env
    }()

    mutating func configureForPlatform(traitCollection: UITraitCollection?) {
        guard let traitCollection else {
            plist.set(Self.configuredForPlatform.plist)
            return
        }
        if plist.isIdentical(to: Self.configuredForPlatform.plist) {
            plist = .init()
        }
        _configureForPlatform(traitCollection: traitCollection)
    }

    private mutating func _configureForPlatform(traitCollection: UITraitCollection?) {
        // defaultAccentColorProvider = OpenSwiftUIDefaultAccentColorProvider.self
        #if OPENSWIFTUI_LINK_COREUI
        cuiNamedColorProvider = KitCoreUINamedColorProvider.self
        #endif
        // resolvedTextProvider = OpenSwiftUIResolvedTextProvider.self
        // hasSystemOpenURLAction = true
        // bridgedEnvironmentResolver = UITraitBridgedEnvironmentResolver.self
        #if OPENSWIFTUI_LINK_COREUI
        let idiom = traitCollection?.userInterfaceIdiom ?? UIDevice.current.userInterfaceIdiom
        cuiAssetIdiom = _CUIIdiomForIdiom(idiom).rawValue
        cuiAssetSubtype = Int(_CUISubtypeForIdiom(idiom).rawValue)
        cuiAssetMatchTypes = CatalogAssetMatchType.defaultValue(idiom: _CUIIdiomForIdiom(idiom).rawValue)
        #endif
    }
}

#endif
