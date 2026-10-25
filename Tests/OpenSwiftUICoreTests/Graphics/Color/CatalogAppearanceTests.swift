//
//  CatalogAppearanceTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc))
struct CatalogAppearanceTests {
    #if os(macOS) && OPENSWIFTUI_LINK_COREUI
    @Test(arguments: [ColorScheme.light, .dark])
    func resolvesLinkColor(_ colorScheme: ColorScheme) throws {
        var environment = EnvironmentValues()
        environment.colorScheme = colorScheme
        let asset = try #require(environment.appearance(allowsVibrantBlending: nil).asset(
            for: CoreUISystemCatalogColorName(rawValue: "linkColor")
        ))
        #expect(asset.0.opacity == 1)
        #expect(asset.1 == .normal)
    }

    @Test
    func skipsAccentForUntintedColors() throws {
        let appearance = try #require(CatalogAppearance.light)
        var calls = 0
        func accent() -> Color.Resolved {
            calls += 1
            return .red
        }
        let name = CoreUISystemCatalogColorName(rawValue: "linkColor")
        #expect(appearance.containsAsset(for: name))
        for _ in 0..<2 {
            #expect(appearance.asset(for: name, accentColor: accent()) != nil)
        }
        #expect(calls == 0)
    }

    @Test
    func selectedControlColorUsesEachTint() throws {
        let appearance = try #require(CatalogAppearance.light)
        let name = CoreUISystemCatalogColorName(rawValue: "alternateSelectedControlColor")
        #expect(appearance.containsAsset(for: name))
        var calls = 0
        func accent(_ color: Color.Resolved) -> Color.Resolved {
            calls += 1
            return color
        }
        let red = try #require(appearance.asset(for: name, accentColor: accent(.red)))
        let blue = try #require(appearance.asset(for: name, accentColor: accent(.blue)))
        #expect(calls == 2)
        #expect(red.0.linearRed > blue.0.linearRed)
        #expect(blue.0.linearBlue > red.0.linearBlue)
        #expect(red.1 == .normal)
        #expect(blue.1 == .normal)
    }

    @Test
    func keepsVibrantBlendOnlyForOpaqueGray() throws {
        let appearance = try #require(CatalogAppearance.vibrantLight)
        let gray = try #require(appearance.asset(for: CoreUISystemCatalogColorName.controlText))
        let link = try #require(appearance.asset(for: CoreUISystemCatalogColorName(rawValue: "linkColor")))
        #expect(gray.0.opacity == 1)
        #expect(gray.0.linearRed == gray.0.linearGreen)
        #expect(gray.0.linearRed == gray.0.linearBlue)
        #expect(gray.1 == .plusDarker)
        #expect(link.1 == .normal)
    }

    @Test
    func missingAssetsAndCatalogsReturnNil() {
        let appearance = CatalogAppearance.base
        let name = CoreUISystemCatalogColorName(rawValue: "OpenSwiftUI.MissingColor")
        #expect(!appearance.containsAsset(for: name))
        #expect(appearance.asset(for: name) == nil)
        #expect(!appearance.containsAsset(for: UnsupportedKey()))
        #expect(appearance.asset(for: UnsupportedKey()) == nil)
        #expect(CatalogAppearance(named: "OpenSwiftUI.MissingCatalog", bundle: appearance.bundle) == nil)
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func graphiteOverridesKeepBaseCatalogs(_ colorScheme: ColorScheme) throws {
        var environment = EnvironmentValues()
        environment.colorScheme = colorScheme
        environment.systemAccentValue = .graphite
        environment._colorSchemeContrast = .increased
        let appearance = try #require(environment.appearance(allowsVibrantBlending: nil) as? _ResolvedCompositeAppearance)
        let names = appearance.appearanceStack.compactMap { ($0 as? CatalogAppearance)?.name }
        if colorScheme == .light {
            #expect(names == ["SystemAppearance", "Aqua", "Graphite", "AquaAX", "GraphiteAX"])
        } else {
            #expect(names == ["SystemAppearance", "DarkAqua", "DarkGraphite", "DarkAquaAX", "DarkGraphiteAX"])
        }
    }

    @Test(arguments: [false, true])
    func explicitVibrancyOverridesEnvironment(_ allowsBlending: Bool) throws {
        var environment = EnvironmentValues()
        environment.colorScheme = .light
        environment.backgroundMaterial = .regular
        environment.allowsVibrantBlending = !allowsBlending
        let appearance = try #require(environment.appearance(allowsVibrantBlending: allowsBlending) as? _ResolvedCompositeAppearance)
        let names = appearance.appearanceStack.compactMap { ($0 as? CatalogAppearance)?.name }
        if allowsBlending {
            #expect(names == ["SystemAppearance", "Aqua", "FauxVibrantLight", "VibrantLight"])
        } else {
            #expect(names == ["SystemAppearance", "Aqua", "FauxVibrantLight"])
        }
    }

    @Test
    func highContrastMaterialKeepsAccessibilityOverridesWithoutVibrancy() throws {
        var environment = EnvironmentValues()
        environment.colorScheme = .dark
        environment._colorSchemeContrast = .increased
        environment.backgroundMaterial = .regular
        environment.allowsVibrantBlending = false
        let appearance = try #require(environment.appearance(allowsVibrantBlending: nil) as? _ResolvedCompositeAppearance)
        let names = appearance.appearanceStack.compactMap { ($0 as? CatalogAppearance)?.name }
        #expect(names == ["SystemAppearance", "DarkAqua", "DarkAquaAX", "FauxVibrantDark", "DarkAquaAX", "VibrantDarkAX"])
    }

    @Test
    func touchBarBypassesAppearanceStack() throws {
        var environment = EnvironmentValues()
        environment.isInTouchBar = true
        environment.colorScheme = .dark
        environment.backgroundMaterial = .regular
        let appearance = try #require(environment.appearance(allowsVibrantBlending: nil) as? CatalogAppearance)
        #expect(appearance.name == "FunctionRowAppearance")
    }

    private struct UnsupportedKey: AppearanceAssetKey {
        typealias AssetType = Int
    }
    #endif
}
