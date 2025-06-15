//
//  NamedColor.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: F70ADAD69423F89598F901BDE477D497 (SwiftUICore)

#if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI
public import Foundation
import CoreUI

// MARK: - NamedColor [6.4.41]

extension Color {
    /// Creates a color from a color set that you indicate by name.
    ///
    /// Use this initializer to load a color from a color set stored in an
    /// Asset Catalog. The system determines which color within the set to use
    /// based on the environment at render time. For example, you
    /// can provide light and dark versions for background and foreground
    /// colors:
    ///
    /// ![A screenshot of color sets for foreground and background colors,
    ///   each with light and dark variants,
    ///   in an Asset Catalog.](Color-init-1)
    ///
    /// You can then instantiate colors by referencing the names of the assets:
    ///
    ///     struct Hello: View {
    ///         var body: some View {
    ///             ZStack {
    ///                 Color("background")
    ///                 Text("Hello, world!")
    ///                     .foregroundStyle(Color("foreground"))
    ///             }
    ///             .frame(width: 200, height: 100)
    ///         }
    ///     }
    ///
    /// OpenSwiftUI renders the appropriate colors for each appearance:
    ///
    /// ![A side by side comparison of light and dark appearance screenshots
    ///   of the same content. The light variant shows dark text on a light
    ///   background, while the dark variant shows light text on a dark
    ///   background.](Color-init-2)
    ///
    /// - Parameters:
    ///   - name: The name of the color resource to look up.
    ///   - bundle: The bundle in which to search for the color resource.
    ///     If you don't indicate a bundle, the initializer looks in your app's
    ///     main bundle by default.
    public init(_ name: String, bundle: Bundle? = nil) {
        self.init(provider: NamedColor(name: name, bundle: bundle))
    }

    /// A way to specify where to load "main bundle" colors from.
    public static let _mainNamedBundle: Bundle? = nil

    private struct NamedColor: ColorProvider {
        var name: String

        var bundle: Bundle?

        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            guard let cgColor = resolveCGColor(in: environment) else {
                let bundlePath = if let bundle {
                    bundle.bundlePath
                } else {
                    "main bundle (\(Bundle.main.bundlePath)"
                }
                Log.externalWarning("No color named '\(name)' found in asset catalog for \(bundlePath)")
                return .clear
            }
            return Resolved(failableCGColor: cgColor) ?? .clear
        }

        func resolveCGColor(in environment: EnvironmentValues) -> CGColor? {
            let key = ColorCacheKey(
                catalogKey: CatalogKey(environment),
                displayGamut: environment.displayGamut,
                name: name,
                bundle: bundle
            )
            return colorCache.access { cache -> CGColor? in
                let colorInfo: NamedColorInfo
                if let info = cache[key] {
                    colorInfo = info
                } else {
                    guard let catalog = CUICatalog.defaultUICatalog(for: bundle) else {
                        return nil
                    }
                    let gamut = key.displayGamut.cuiDisplayGamut
                    let idiom = CUIDeviceIdiom(rawValue: environment.cuiAssetIdiom) ?? .universal
                    let color = catalog.findAsset(
                        key: key.catalogKey,
                        matchTypes: environment.cuiAssetMatchTypes,
                    ) { appearanceName -> CUINamedColor? in
                        let color = catalog.color(
                            withName: name,
                            displayGamut: gamut,
                            deviceIdiom: idiom,
                            appearanceName: appearanceName
                        )
                        return color
                    }
                    let info = NamedColorInfo(color: color)
                    cache[key] = info
                    colorInfo = info
                }
                guard let color = colorInfo.color else {
                    return nil
                }
                return color.effectiveCGColor(in: environment)
            }
        }
    }
}

private struct NamedColorInfo {
    var color: CUINamedColor?
}

private struct ColorCacheKey: Hashable {
    var catalogKey: CatalogKey
    var displayGamut: DisplayGamut
    var name: String
    var bundle: Bundle?
}

private let colorCache: AtomicBox<[ColorCacheKey: NamedColorInfo]> = AtomicBox(wrappedValue: [:])

extension CUINamedColor {
    fileprivate func effectiveCGColor(in environment: EnvironmentValues) -> CGColor? {
        guard substituteWithSystemColor,
              let colorProviderType = environment.cuiNamedColorProvider
        else {
            return cgColor
        }
        return colorProviderType.effectiveCGColor(cuiColor: self, in: environment)
    }
}

extension CUICatalog {
    func findAsset<Asset, AssetMatchTypes>(key: CatalogKey, matchTypes: AssetMatchTypes, assetLookup: (String) -> Asset?) -> Asset?
        where Asset: CUINamedLookup,
        AssetMatchTypes: Collection,
        AssetMatchTypes.Element == CatalogAssetMatchType
    {
        guard !matchTypes.isEmpty else {
            return nil
        }
        let colorScheme = key.colorScheme
        let contrast = key.contrast
        for matchType in matchTypes {
            let isVision = matchType == .cuiIdiom(8)
            let appearanceConfigurations: [(ColorScheme?, ColorSchemeContrast)]
            switch (contrast, isVision) {
            case (.standard, false):
                appearanceConfigurations = [(colorScheme, .standard), (nil, .standard)]
            case (.standard, true):
                appearanceConfigurations = [(nil, .standard)]
            case (.increased, false):
                appearanceConfigurations = [(colorScheme, .increased), (colorScheme, .standard), (nil, .increased), (nil, .standard)]
            case (.increased, true):
                appearanceConfigurations = [(nil, .increased), (nil, .standard)]
            }
            for (scheme, contrast) in appearanceConfigurations {
                // FIXME: macOS should use NSAppearanceNameSystem and other stuff
                let appearanceName = switch (scheme, contrast) {
                case (nil, .standard): "UIAppearanceAny"
                case (nil, .increased): "UIAppearanceHighContrastAny"
                case (.light, .standard): "UIAppearanceLight"
                case (.light, .increased): "UIAppearanceHighContrastLight"
                case (.dark, .standard): "UIAppearanceDark"
                case (.dark, .increased): "UIAppearanceHighContrastDark"
                }
                guard let asset = assetLookup(appearanceName) else {
                    continue
                }
                switch matchType {
                case .always:
                    break
                case .appearance:
                    guard asset.appearance == appearanceName else {
                        continue
                    }
                case let .cuiIdiom(idiomValue):
                    guard asset.idiom.rawValue == idiomValue else {
                        continue
                    }
                }
                return asset
            }
        }
        return nil
    }
}

#endif

#if canImport(Darwin) && canImport(DeveloperToolsSupport)

public import DeveloperToolsSupport

// MARK: - Color + ColorResource [TODO]

extension Color {
    /// Initialize a `Color` with a color resource.
    public init(_ resource: ColorResource) {
        preconditionFailure("TODO")
    }
}
#endif
