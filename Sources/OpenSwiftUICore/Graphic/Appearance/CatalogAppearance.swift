//
//  CatalogAppearance.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D5261B14264A5DF0B53BDE4A9E2F71F9 (SwiftUICore)

#if os(macOS) && OPENSWIFTUI_LINK_COREUI
import CoreGraphics_Private
package import CoreUI
import Foundation

// MARK: - CatalogAppearance

package struct CatalogAppearance: _ResolvedAppearance, Hashable {
    package let renderer: CUIRendererRef
    package let catalog: CUICatalog
    package let name: String
    package let bundle: Bundle
    private let defaultBlendMode: BlendMode

    package init?(named name: String, bundle: Bundle) {
        let options = [
            kCUIRendererThemeFileBundleIdentifierKey as String: bundle.bundleIdentifier!,
            kCUIRendererThemeFileNameKey as String: name,
        ] as CFDictionary
        guard let renderer = CUICreateRenderer(options) else {
            return nil
        }
        var properties: Unmanaged<CFDictionary>?
        CUIRendererCopyProperties(renderer, [kCUIRendererDefaultBlendModeKey] as CFArray, &properties)
        var blendMode = BlendMode.normal
        if let properties {
            let values = properties.takeRetainedValue() as! [String: NSNumber]
            if let value = values[kCUIRendererDefaultBlendModeKey as String] {
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

    package func containsDefinition<W>(for widget: W) -> Bool where W: AppearanceWidgetDefinition {
        guard let widget = widget as? any CoreUIAppearanceWidget else { return false }
        if name == Self.baseName, bundle.bundleIdentifier == "com.apple.systemappearance" {
            let key = widget.coreUIWidgetKey
            if key == kCUIWidgetTitleBarCloseBox as String ||
                key == kCUIWidgetDisclosureTriangle as String ||
                key == kCUIWidgetOverlayScrollBar as String {
                return true
            }
        }
        return catalog.hasCustomizedAppearance(forWidget: widget.coreUIWidgetKey)
    }

    package func asset<K>(
        for key: K,
        accentColor: @autoclosure () -> Color.Resolved
    ) -> K.AssetType? where K: AppearanceAssetKey {
        if let name = key as? CoreUISystemCatalogColorName {
            if let cgColor = untintedColor(named: name) {
                let color = Color.Resolved(failableCGColor: cgColor) ?? .clear
                let blendMode: BlendMode
                if defaultBlendMode != .normal,
                   color.linearBlue == color.linearGreen,
                   color.linearRed == color.linearBlue,
                   color.opacity == 1 {
                    blendMode = defaultBlendMode
                } else {
                    blendMode = .normal
                }
                return (color, blendMode) as? K.AssetType
            }
            let cacheKey = ColorCacheKey(appearance: self, name: name, tintColor: accentColor().cgColor)
            guard let cgColor = Self.cgColorCache[cacheKey] else { return nil }
            let color = Color.Resolved(failableCGColor: cgColor) ?? .clear
            return (color, BlendMode.normal) as? K.AssetType
        }
        if let metric = key as? any AnyAppearanceWidgetMetricKey {
            return metric.metric(in: self).map { $0 as! K.AssetType }
        }
        if let artwork = key as? any AnyAppearanceWidgetArtworkKey {
            return artwork.artwork(in: self).map { $0 as! K.AssetType }
        }
        if let glyph = key as? AppearanceGlyphEffectKey {
            let cacheKey = GlyphEffectCacheKey(
                appearance: self,
                configuration: glyph.configuration,
                tintColor: accentColor().cgColor
            )
            return Self.effectCache[cacheKey].map { $0 as! K.AssetType }
        }
        return nil
    }

    package func containsAsset<K>(for key: K) -> Bool where K: AppearanceAssetKey {
        if let name = key as? CoreUISystemCatalogColorName {
            if untintedColor(named: name) != nil { return true }
            let cacheKey = ColorCacheKey(appearance: self, name: name, tintColor: CGColor(gray: 1, alpha: 1))
            return Self.cgColorCache[cacheKey] != nil
        }
        if let metric = key as? any AnyAppearanceWidgetMetricKey {
            return metric.hasDefinition(in: self)
        }
        if let artwork = key as? any AnyAppearanceWidgetArtworkKey {
            return artwork.hasDefinition(in: self)
        }
        if let glyph = key as? AppearanceGlyphEffectKey {
            let cacheKey = GlyphEffectCacheKey(appearance: self, configuration: glyph.configuration, tintColor: nil)
            return Self.effectCache[cacheKey] != nil
        }
        return false
    }

    private func untintedColor(named name: CoreUISystemCatalogColorName) -> CGColor? {
        guard name.rawValue != "alternateSelectedControlColor" else { return nil }
        return Self.cgColorCache[ColorCacheKey(appearance: self, name: name, tintColor: nil)]
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
            [kCUIForegroundTintColor as String: key.tintColor as Any] as CFDictionary
        )
    }

    private struct GlyphEffectCacheKey: Hashable {
        var appearance: CatalogAppearance
        var configuration: AppearanceStyleEffectConfiguration
        var tintColor: CGColor?
    }

    private static let effectCache = ObjectCache<GlyphEffectCacheKey, AppearanceGlyphEffect?> { key in
        let configuration = key.configuration.coreUIConfiguration
        if key.appearance.name == touchBarName {
            configuration.colorTemperature = 7500
            configuration.brightnessMultiplier = 1
        }
        let catalog = key.appearance.catalog
        guard let foreground = catalog.equivalentForegroundColorForStylePreset(
            withName: nil, styleConfiguration: configuration, baseForegroundColor: key.tintColor
        ) else { return nil }
        let color = Color.Resolved(failableCGColor: foreground) ?? .clear
        let filter = catalog.compositingFilterForStylePreset(
            withName: nil, styleConfiguration: configuration, foregroundColor: key.tintColor
        )
        return AppearanceGlyphEffect(foregroundColor: color, filter: filter as AnyObject?)
    }
}

// MARK: - System appearances

extension CatalogAppearance {
    package static let baseName = "SystemAppearance"
    package static let base = CatalogAppearance(named: baseName, bundle: .systemAppearance)!

    package static let lightName = "Aqua"
    package static let light = CatalogAppearance(named: lightName, bundle: .systemAppearance)
    package static let lightGraphiteName = "Graphite"
    package static let lightGraphite = CatalogAppearance(named: lightGraphiteName, bundle: .systemAppearance)

    package static let vibrantLightName = "VibrantLight"
    package static let vibrantLight = CatalogAppearance(named: vibrantLightName, bundle: .systemAppearance)
    package static let vibrantLightGraphiteName = "VibrantLightGraphite"
    package static let vibrantLightGraphite = CatalogAppearance(named: vibrantLightGraphiteName, bundle: .systemAppearance)

    package static let fauxVibrantLightName = "FauxVibrantLight"
    package static let fauxVibrantLight = CatalogAppearance(named: fauxVibrantLightName, bundle: .systemAppearance)
    package static let fauxVibrantLightGraphiteName = "FauxVibrantLightGraphite"
    package static let fauxVibrantLightGraphite = CatalogAppearance(named: fauxVibrantLightGraphiteName, bundle: .systemAppearance)

    package static let darkName = "DarkAqua"
    package static let dark = CatalogAppearance(named: darkName, bundle: .systemAppearance)
    package static let darkGraphiteName = "DarkGraphite"
    package static let darkGraphite = CatalogAppearance(named: darkGraphiteName, bundle: .systemAppearance)

    package static let vibrantDarkName = "VibrantDark"
    package static let vibrantDark = CatalogAppearance(named: vibrantDarkName, bundle: .systemAppearance)
    package static let vibrantDarkGraphiteName = "VibrantDarkGraphite"
    package static let vibrantDarkGraphite = CatalogAppearance(named: vibrantDarkGraphiteName, bundle: .systemAppearance)

    package static let fauxVibrantDarkName = "FauxVibrantDark"
    package static let fauxVibrantDark = CatalogAppearance(named: fauxVibrantDarkName, bundle: .systemAppearance)!
    package static let fauxVibrantDarkGraphiteName = "FauxVibrantDarkGraphite"
    package static let fauxVibrantDarkGraphite = CatalogAppearance(named: fauxVibrantDarkGraphiteName, bundle: .systemAppearance)

    package static let axLightName = "AquaAX"
    package static let axLight = CatalogAppearance(named: axLightName, bundle: .systemAppearance)
    package static let axLightGraphiteName = "GraphiteAX"
    package static let axLightGraphite = CatalogAppearance(named: axLightGraphiteName, bundle: .systemAppearance)

    package static let axVibrantLightName = "VibrantLightAX"
    package static let axVibrantLight = CatalogAppearance(named: axVibrantLightName, bundle: .systemAppearance)
    package static let axVibrantLightGraphiteName = "VibrantLightGraphiteAX"
    package static let axVibrantLightGraphite = CatalogAppearance(named: axVibrantLightGraphiteName, bundle: .systemAppearance)

    package static let axDarkName = "DarkAquaAX"
    package static let axDark = CatalogAppearance(named: axDarkName, bundle: .systemAppearance)
    package static let axDarkGraphiteName = "DarkGraphiteAX"
    package static let axDarkGraphite = CatalogAppearance(named: axDarkGraphiteName, bundle: .systemAppearance)

    package static let axVibrantDarkName = "VibrantDarkAX"
    package static let axVibrantDark = CatalogAppearance(named: axVibrantDarkName, bundle: .systemAppearance)
    package static let axVibrantDarkGraphiteName = "VibrantDarkGraphiteAX"
    package static let axVibrantDarkGraphite = CatalogAppearance(named: axVibrantDarkGraphiteName, bundle: .systemAppearance)

    package static let touchBarName = "FunctionRowAppearance"
    package static let touchBar = CatalogAppearance(named: touchBarName, bundle: .systemAppearance)!
    package static let controlStrip = CatalogAppearance(named: "ControlStripAppearance", bundle: .systemAppearance)
    package static let touchBarCustomizationPalette = CatalogAppearance(
        named: "TouchBarCustomizationPaletteAppearance", bundle: .systemAppearance
    )
    package static let controlStripCustomizationPalette = CatalogAppearance(
        named: "ControlStripCustomizationPaletteAppearance", bundle: .systemAppearance
    )
}

// MARK: - AppearanceWidgetArtworkProviding

extension CatalogAppearance: AppearanceWidgetArtworkProviding {
    func containsDefinition<W>(for key: AppearanceWidgetArtworkKey<W>) -> Bool {
        containsDefinition(for: key.widget)
    }

    func artwork<W>(for key: AppearanceWidgetArtworkKey<W>) -> Image? {
        guard let definition = key.widget as? any CoreUIAppearanceWidget else { return nil }
        if let image = AppearanceWidgetAssetCache.named(name).cachedArtwork(for: key.widget) {
            return image
        }
        guard containsDefinition(for: key.widget) else { return nil }
        var options = definition.coreUIOptions
        if name == Self.touchBarName {
            options[kCUIBezelTintColor as String] = untintedColor(named: "controlColor")
            options[kCUIColorTemperatureAdjustment as String] = 7500
            options[kCUIBezelBrightnessMultiplier as String] = 0.8
            options[kCUITextGlyphBrightnessMultiplier as String] = 1.0
        }
        let image: Image?
        switch definition.coreUIRenderer {
        case .layer:
            image = layerImage(options: options)
        case let .drawing(provider):
            guard let traits = metric(for: AppearanceWidgetMetricKey(metric: layoutTraitsMetricName, for: key.widget)) else {
                return nil
            }
            let drawingOptions = provider.options(for: traits)
            guard drawingOptions.boundsSize.width > 0, drawingOptions.boundsSize.height > 0 else { return nil }
            image = CUIDrawBasedImage(options: options, drawingOptions: drawingOptions)?
                .resizable(capInsets: drawingOptions.capInsets)
        }
        if let image {
            AppearanceWidgetAssetCache.named(name).cacheArtwork(image, with: key.widget)
        }
        return image
    }

    private func CUIDrawBasedImage(
        options: [String: Any],
        drawingOptions: CoreUIWidgetRendererType.DrawingOptions
    ) -> Image? {
        let size = drawingOptions.boundsSize
        let crop = drawingOptions.cropInsets
        let scale = drawingOptions.displayScale
        let width = Int((size.width - crop.leading - crop.trailing) * scale)
        let height = Int((size.height - crop.top - crop.bottom) * scale)
        guard let context = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        context.scaleBy(x: scale, y: scale)
        CGContextSetBaseCTM(context, context.ctm)
        let bounds = CGRect(origin: CGPoint(x: -crop.leading, y: -crop.bottom), size: size)
        _ = CUIDraw(renderer, bounds, context, options as CFDictionary, nil)
        guard let image = context.makeImage() else { return nil }
        return Image(decorative: image, scale: scale)
    }

    private func layerImage(options: [String: Any]) -> Image? {
        var contents: Unmanaged<CGImage>?
        var center = CGRect.zero
        let status = CUICreateLayerContents(renderer, options as CFDictionary, &contents, &center)
        guard let image = contents?.takeRetainedValue(), status != -4 else { return nil }
        let maxScale = CGFloat(CUIMaxScaleForTargetPlatform(CUICurrentPlatform()))
        let scale = min(options[kCUIScaleKey as String] as? CGFloat ?? 1, maxScale)
        let artwork = Image(decorative: image, scale: scale)
        guard center != CGRect(x: 0, y: 0, width: 1, height: 1) else { return artwork }

        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        let flipped = options[kCUIIsFlippedKey as String] as? Bool ?? false
        let minYInset = center.minY * height / scale
        let maxYInset = (1 - center.maxY) * height / scale
        let insets = EdgeInsets(
            top: flipped ? minYInset : maxYInset,
            leading: center.minX * width / scale,
            bottom: flipped ? maxYInset : minYInset,
            trailing: (1 - center.maxX) * width / scale
        )
        return artwork.resizable(capInsets: insets)
    }
}

// MARK: - AppearanceWidgetMetricProviding

extension CatalogAppearance: AppearanceWidgetMetricProviding {
    func containsDefinition<W, Value>(for key: AppearanceWidgetMetricKey<W, Value>) -> Bool {
        containsDefinition(for: key.widget) && metric(for: key) != nil
    }

    func metric<W, Value>(for key: AppearanceWidgetMetricKey<W, Value>) -> Value? {
        guard let keys = key.metric.coreUIKeys, let definition = key.widget as? any CoreUIAppearanceWidget else {
            return nil
        }
        if let value = AppearanceWidgetAssetCache.named(name).cachedMetric(key.metric, for: key.widget) {
            return value
        }
        var measurements: Unmanaged<CFDictionary>?
        _ = CUICopyMeasurements(
            renderer, CGRect(x: 0, y: 0, width: 1000, height: 1000), nil,
            definition.coreUIOptions as CFDictionary, keys as CFArray, &measurements
        )
        let values = measurements.map { $0.takeRetainedValue() as! [String: NSValue] }
        let measuredValue = values.flatMap(key.metric.valueIn(coreUIMetricsDictionary:))
        let metric = definition.coreUIAdjustMetric(key: key.metric, value: measuredValue, for: self)
        if let metric {
            AppearanceWidgetAssetCache.named(name).cacheMetric(metric, for: key.metric, with: key.widget)
        }
        return metric
    }
}

// MARK: - System appearance bundle

extension Bundle {
    fileprivate static let systemAppearance = createSystemAppearanceBundle()

    private static func createSystemAppearanceBundle() -> Bundle {
        let library = FileManager.default.urls(for: .libraryDirectory, in: .systemDomainMask).first!
        let url = library
            .appendingPathComponent("CoreServices", isDirectory: true)
            .appendingPathComponent("SystemAppearance.bundle")
        return Bundle(url: url)!
    }
}
#endif
