//
//  CatalogAppearance.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: D5261B14264A5DF0B53BDE4A9E2F71F9 (SwiftUICore)

#if os(macOS) && OPENSWIFTUI_LINK_COREUI
package import CoreUI

package struct CatalogAppearance: _ResolvedAppearance, Hashable {
    package let renderer: OpaquePointer
    package let catalog: CUICatalog
    package let name: String
    package let bundle: Bundle
    let defaultBlendMode: BlendMode

    package init?(named name: String, bundle: Bundle) {
        let options = [
            kCUIRendererThemeFileBundleIdentifierKey as String: bundle.bundleIdentifier!,
            kCUIRendererThemeFileNameKey as String: name,
        ] as CFDictionary
        guard let renderer = CUICreateRenderer(options) else {
            return nil
        }
        var properties: Unmanaged<CFDictionary>?
        CUIRendererCopyProperties(renderer, ["defaultBlendMode"] as CFArray, &properties)
        var blendMode = BlendMode.normal
        if let properties {
            let values = properties.takeRetainedValue() as! [String: NSNumber]
            if let value = values["defaultBlendMode"] {
                let rawValue = Int32(value.uintValue)
                blendMode = BlendMode(CGBlendMode(rawValue: rawValue) ?? .normal)
            }
        }
        guard let catalog = try? CUICatalog(name: name, from: bundle, error: ()) else {
            return nil
        }
        self.renderer = renderer
        self.catalog = catalog
        self.name = name
        self.bundle = bundle
        self.defaultBlendMode = blendMode
    }

    package func asset<K>(
        for key: K,
        accentColor: @autoclosure () -> Color.Resolved
    ) -> K.AssetType? where K: AppearanceAssetKey {
        // TODO: Widget artwork, metrics, and glyph effects.
        guard let name = key as? CoreUISystemCatalogColorName else {
            return nil
        }
        var cacheKey = ColorCacheKey(appearance: self, name: name, tintColor: nil)
        if name.rawValue != "alternateSelectedControlColor",
           let cgColor = Self.cgColorCache[cacheKey] {
            let color = Color.Resolved(failableCGColor: cgColor) ?? .clear
            let blendMode: BlendMode
            if defaultBlendMode != .normal,
               color.linearRed == color.linearGreen,
               color.linearRed == color.linearBlue,
               color.opacity == 1 {
                blendMode = defaultBlendMode
            } else {
                blendMode = .normal
            }
            return (color, blendMode) as? K.AssetType
        }
        cacheKey.tintColor = accentColor().cgColor
        guard let cgColor = Self.cgColorCache[cacheKey] else {
            return nil
        }
        let color = Color.Resolved(failableCGColor: cgColor) ?? .clear
        return (color, BlendMode.normal) as? K.AssetType
    }

    package func containsAsset<K>(for key: K) -> Bool where K: AppearanceAssetKey {
        guard let name = key as? CoreUISystemCatalogColorName else {
            return false
        }
        var cacheKey = ColorCacheKey(appearance: self, name: name, tintColor: nil)
        if name.rawValue != "alternateSelectedControlColor",
           Self.cgColorCache[cacheKey] != nil {
            return true
        }
        cacheKey.tintColor = CGColor(gray: 1, alpha: 1)
        return Self.cgColorCache[cacheKey] != nil
    }

    package func isEqual(to other: any _ResolvedAppearance) -> Bool {
        guard let other = other as? CatalogAppearance else {
            return false
        }
        return self == other
    }

    package static func == (lhs: CatalogAppearance, rhs: CatalogAppearance) -> Bool {
        lhs.name == rhs.name && lhs.bundle == rhs.bundle
    }

    package func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(bundle)
    }

    private struct ColorCacheKey: Hashable {
        var appearance: CatalogAppearance
        var name: CoreUISystemCatalogColorName
        var tintColor: CGColor?
    }

    private static let cgColorCache = ObjectCache<ColorCacheKey, CGColor?> { key in
        CUICopyCustomColorWithOptions(
            key.appearance.renderer,
            key.name.rawValue as CFString,
            ["kCUIForegroundTintColor": key.tintColor as Any] as CFDictionary
        )
    }

    package static var baseName: String { "SystemAppearance" }
    package static let base = CatalogAppearance(named: baseName, bundle: .systemAppearance)!

    package static var lightName: String { "Aqua" }
    package static let light = CatalogAppearance(named: lightName, bundle: .systemAppearance)
    package static var lightGraphiteName: String { "Graphite" }
    package static let lightGraphite = CatalogAppearance(named: lightGraphiteName, bundle: .systemAppearance)

    package static var vibrantLightName: String { "VibrantLight" }
    package static let vibrantLight = CatalogAppearance(named: vibrantLightName, bundle: .systemAppearance)
    package static var vibrantLightGraphiteName: String { "VibrantLightGraphite" }
    package static let vibrantLightGraphite = CatalogAppearance(named: vibrantLightGraphiteName, bundle: .systemAppearance)

    package static var fauxVibrantLightName: String { "FauxVibrantLight" }
    package static let fauxVibrantLight = CatalogAppearance(named: fauxVibrantLightName, bundle: .systemAppearance)
    package static var fauxVibrantLightGraphiteName: String { "FauxVibrantLightGraphite" }
    package static let fauxVibrantLightGraphite = CatalogAppearance(named: fauxVibrantLightGraphiteName, bundle: .systemAppearance)

    package static var darkName: String { "DarkAqua" }
    package static let dark = CatalogAppearance(named: darkName, bundle: .systemAppearance)
    package static var darkGraphiteName: String { "DarkGraphite" }
    package static let darkGraphite = CatalogAppearance(named: darkGraphiteName, bundle: .systemAppearance)

    package static var vibrantDarkName: String { "VibrantDark" }
    package static let vibrantDark = CatalogAppearance(named: vibrantDarkName, bundle: .systemAppearance)
    package static var vibrantDarkGraphiteName: String { "VibrantDarkGraphite" }
    package static let vibrantDarkGraphite = CatalogAppearance(named: vibrantDarkGraphiteName, bundle: .systemAppearance)

    package static var fauxVibrantDarkName: String { "FauxVibrantDark" }
    package static let fauxVibrantDark = CatalogAppearance(named: fauxVibrantDarkName, bundle: .systemAppearance)!
    package static var fauxVibrantDarkGraphiteName: String { "FauxVibrantDarkGraphite" }
    package static let fauxVibrantDarkGraphite = CatalogAppearance(named: fauxVibrantDarkGraphiteName, bundle: .systemAppearance)

    package static var axLightName: String { "AquaAX" }
    package static let axLight = CatalogAppearance(named: axLightName, bundle: .systemAppearance)
    package static var axLightGraphiteName: String { "GraphiteAX" }
    package static let axLightGraphite = CatalogAppearance(named: axLightGraphiteName, bundle: .systemAppearance)

    package static var axVibrantLightName: String { "VibrantLightAX" }
    package static let axVibrantLight = CatalogAppearance(named: axVibrantLightName, bundle: .systemAppearance)
    package static var axVibrantLightGraphiteName: String { "VibrantLightGraphiteAX" }
    package static let axVibrantLightGraphite = CatalogAppearance(named: axVibrantLightGraphiteName, bundle: .systemAppearance)

    package static var axDarkName: String { "DarkAquaAX" }
    package static let axDark = CatalogAppearance(named: axDarkName, bundle: .systemAppearance)
    package static var axDarkGraphiteName: String { "DarkGraphiteAX" }
    package static let axDarkGraphite = CatalogAppearance(named: axDarkGraphiteName, bundle: .systemAppearance)

    package static var axVibrantDarkName: String { "VibrantDarkAX" }
    package static let axVibrantDark = CatalogAppearance(named: axVibrantDarkName, bundle: .systemAppearance)
    package static var axVibrantDarkGraphiteName: String { "VibrantDarkGraphiteAX" }
    package static let axVibrantDarkGraphite = CatalogAppearance(named: axVibrantDarkGraphiteName, bundle: .systemAppearance)

    package static var touchBarName: String { "FunctionRowAppearance" }
    package static let touchBar = CatalogAppearance(named: touchBarName, bundle: .systemAppearance)!
}

extension Bundle {
    fileprivate static let systemAppearance = createSystemAppearanceBundle()

    fileprivate static func createSystemAppearanceBundle() -> Bundle {
        let library = FileManager.default.urls(for: .libraryDirectory, in: .systemDomainMask).first!
        let url = library
            .appendingPathComponent("CoreServices", isDirectory: true)
            .appendingPathComponent("SystemAppearance.bundle")
        return Bundle(url: url)!
    }
}
#endif
