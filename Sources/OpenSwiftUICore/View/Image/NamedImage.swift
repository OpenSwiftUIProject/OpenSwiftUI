//
//  NamedImage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 8E7DCD4CEB1ACDE07B249BFF4CBC75C0 (SwiftUICore)

public import Foundation
package import OpenCoreGraphicsShims
#if canImport(CoreGraphics)
import CoreGraphics_Private
#endif
#if OPENSWIFTUI_LINK_COREUI
package import CoreUI
import GraphicsServices_Private
#endif

// MARK: - NamedImage

package enum NamedImage {

    // MARK: - NamedImage.VectorKey

    package struct VectorKey: Hashable {
        package var catalogKey: CatalogKey

        package var name: String

        package var scale: CGFloat

        package var layoutDirection: LayoutDirection

        package var locale: Locale

        package var weight: Font.Weight

        package var imageScale: Image.HashableScale

        package var pointSize: CGFloat

        package var location: Image.Location

        package var idiom: Int

        package init(
            name: String,
            location: Image.Location,
            in env: EnvironmentValues,
            textStyle: Text.Style?,
            idiom: Int
        ) {
            self.catalogKey = CatalogKey(env)
            self.name = name
            self.scale = env.displayScale
            self.layoutDirection = env.layoutDirection
            self.locale = env.locale
            let traits: Font.ResolvedTraits
            if let textStyle {
                traits = textStyle.fontTraits(in: env)
            } else {
                traits = env.effectiveSymbolFont.resolveTraits(in: env)
            }
            var resolvedWeight = Font.Weight(value: traits.weight)
            if let legibilityWeight = env.legibilityWeight, legibilityWeight == .bold {
                #if canImport(CoreText)
                // Adjust for accessibility bold weight if legibility weight is .bold
                resolvedWeight = Font.Weight(value: CGFloat(CTFontGetAccessibilityBoldWeightOfWeight(CGFloat(resolvedWeight.value))))
                #endif
            }
            self.weight = resolvedWeight
            self.imageScale = Image.HashableScale(env.imageScale)
            self.pointSize = traits.pointSize
            self.location = location
            self.idiom = idiom
        }

        #if OPENSWIFTUI_LINK_COREUI
        fileprivate func loadVectorInfo(from catalog: CUICatalog, idiom: Int) -> VectorInfo? {
            let matchType: CatalogAssetMatchType = .cuiIdiom(idiom)
            let glyph: CUINamedVectorGlyph? = catalog.findAsset(
                key: catalogKey,
                matchTypes: CollectionOfOne(matchType)
            ) { appearanceName -> CUINamedVectorGlyph? in
                let cuiIdiom = CUIDeviceIdiom(rawValue: idiom)!
                let cuiLayoutDir = self.layoutDirection.cuiLayoutDirection
                let glyphSz = self.imageScale.glyphSize
                let glyphWt = self.weight.glyphWeight
                guard var result = catalog.namedVectorGlyph(
                    withName: self.name,
                    scaleFactor: self.scale,
                    deviceIdiom: cuiIdiom,
                    layoutDirection: cuiLayoutDir,
                    glyphSize: glyphSz,
                    glyphWeight: glyphWt,
                    glyphPointSize: self.pointSize,
                    appearanceName: appearanceName,
                    locale: self.locale
                ) else { return nil }

                let sizeScale = self.symbolSizeScale(for: result)
                if sizeScale != 1.0 {
                    let continuousWt = self.weight.glyphContinuousWeight
                    if let rescaled = catalog.namedVectorGlyph(
                        withName: self.name,
                        scaleFactor: self.scale,
                        deviceIdiom: cuiIdiom,
                        layoutDirection: cuiLayoutDir,
                        glyphContinuousSize: sizeScale,
                        glyphContinuousWeight: continuousWt,
                        glyphPointSize: self.pointSize,
                        appearanceName: appearanceName,
                        locale: self.locale
                    ) {
                        result = rescaled
                    }
                }

                return result
            }

            guard let glyph else { return nil }
            let flipsRightToLeft: Bool
            if glyph.isFlippable, glyph.layoutDirection != .unspecified {
                let expectedDirection: CUILayoutDirection = layoutDirection == .leftToRight ? .LTR : .RTL
                flipsRightToLeft = glyph.layoutDirection != expectedDirection
            } else {
                flipsRightToLeft = false
            }

            let metrics = Image.LayoutMetrics(glyph: glyph, flipsRightToLeft: flipsRightToLeft)
            return VectorInfo(
                glyph: glyph,
                flipsRightToLeft: flipsRightToLeft,
                layoutMetrics: metrics,
                catalog: catalog
            )
        }

        /// Computes a scale factor for symbol images based on the glyph's
        /// actual path radius relative to a reference circle.fill size.
        ///
        /// The algorithm:
        /// 1. Gets the allowed scale range for this image scale
        /// 2. Iterates monochrome glyph layers, skipping slash/badge overlays
        /// 3. Computes the maximum radius of all path points from the metric center
        /// 4. Computes a reference circle.fill diameter for the current weight/pointSize
        /// 5. Returns the ratio clamped to the allowed range
        private func symbolSizeScale(for glyph: CUINamedVectorGlyph) -> CGFloat {
            let range = imageScale.allowedScaleRange
            guard range.lowerBound < range.upperBound else {
                return range.lowerBound
            }

            guard let layers = glyph.monochromeLayers else {
                return 1.0
            }

            let center = glyph.metricCenter
            let inverseScale = Float(1.0 / glyph.scale)
            let centerF = SIMD2<Float>(Float(center.x), Float(center.y))

            var maxRadiusSq: Float = 0.0

            for layer in layers {
                guard layer.opacity > 0 else { continue }

                if let tags = layer.tags {
                    if tags.contains("_slash") || tags.contains("_badge") {
                        continue
                    }
                }

                guard let path = layer.shape else { continue }

                // TODO: RBPathApplyLines
                // Iterate path points, computing max squared distance from center.
                // The original uses RBPathApplyLines to flatten curves; here we
                // process all element endpoints which is equivalent for line-based
                // glyph outlines and conservative for curves.
                path.applyWithBlock { elementPointer in
                    let element = elementPointer.pointee
                    let points = element.points
                    let pointCount: Int
                    switch element.type {
                    case .moveToPoint: pointCount = 1
                    case .addLineToPoint: pointCount = 1
                    case .addQuadCurveToPoint: pointCount = 2
                    case .addCurveToPoint: pointCount = 3
                    case .closeSubpath: pointCount = 0
                    @unknown default: pointCount = 0
                    }
                    for i in 0 ..< pointCount {
                        let p = points[i]
                        let scaled = SIMD2<Float>(Float(p.x), Float(p.y)) * inverseScale
                        let delta = scaled - centerF
                        let distSq = delta.x * delta.x + delta.y * delta.y
                        if distSq > maxRadiusSq {
                            maxRadiusSq = distSq
                        }
                    }
                }
            }

            let diameter = imageScale.circleDotFillSize(pointSize: pointSize, weight: weight)
            let referenceRadius = imageScale.maxRadius(diameter: diameter)
            let actualRadius = CGFloat(maxRadiusSq.squareRoot())

            guard actualRadius > 0 else {
                return 1.0
            }

            let ratio = referenceRadius / actualRadius
            return min(range.upperBound, max(range.lowerBound, ratio))
        }
        #endif
    }


    // MARK: - VectorInfo

    fileprivate struct VectorInfo {
        #if OPENSWIFTUI_LINK_COREUI
        var glyph: CUINamedVectorGlyph

        var flipsRightToLeft: Bool

        var layoutMetrics: Image.LayoutMetrics

        weak var catalog: CUICatalog?
        #endif
    }


    // MARK: - NamedImage.BitmapKey [WIP]

    package struct BitmapKey: Hashable {
        package var catalogKey: CatalogKey

        package var name: String

        package var scale: CGFloat

        package var location: Image.Location

        package var layoutDirection: LayoutDirection

        package var locale: Locale

        package var gamut: DisplayGamut

        package var idiom: Int

        package var subtype: Int

        package var horizontalSizeClass: Int8

        package var verticalSizeClass: Int8

        package init(
            name: String,
            location: Image.Location,
            in env: EnvironmentValues
        ) {
            self.catalogKey = CatalogKey(env)
            self.name = name
            self.scale = env.displayScale
            self.location = location
            self.layoutDirection = env.layoutDirection
            self.locale = env.locale
            self.gamut = env.displayGamut
            self.idiom = env.cuiAssetIdiom
            self.subtype = env.cuiAssetSubtype
            self.horizontalSizeClass = Self.convertSizeClass(env.horizontalSizeClass)
            self.verticalSizeClass = Self.convertSizeClass(env.verticalSizeClass)
        }

        package init(
            catalogKey: CatalogKey,
            name: String,
            scale: CGFloat,
            location: Image.Location,
            layoutDirection: LayoutDirection,
            locale: Locale,
            gamut: DisplayGamut,
            idiom: Int,
            subtype: Int,
            horizontalSizeClass: Int8 = 0,
            verticalSizeClass: Int8 = 0
        ) {
            self.catalogKey = catalogKey
            self.name = name
            self.scale = scale
            self.location = location
            self.layoutDirection = layoutDirection
            self.locale = locale
            self.gamut = gamut
            self.idiom = idiom
            self.subtype = subtype
            self.horizontalSizeClass = horizontalSizeClass
            self.verticalSizeClass = verticalSizeClass
        }

        // [TBA]
        // Converts UserInterfaceSizeClass? to Int8:
        // nil -> 0, .compact -> 1, .regular -> 2
        private static func convertSizeClass(_ sizeClass: UserInterfaceSizeClass?) -> Int8 {
            guard let sizeClass else {
                return 0
            }
            switch sizeClass {
            case .compact: return 1
            case .regular: return 2
            }
        }

        #if OPENSWIFTUI_LINK_COREUI
        func loadBitmapInfo(location: Image.Location, idiom: Int, subtype: Int) -> BitmapInfo? {
            // Resolve catalog from location
            guard case .bundle(let bundle) = location,
                  let (catalog, _) = NamedImage.sharedCache[bundle] else {
                // TODO: .system / .privateSystem asset manager support
                return nil
            }

            // Build match types based on idiom
            let matchTypes = CatalogAssetMatchType.defaultValue(idiom: idiom)

            let selfCUIDirection: CUILayoutDirection = layoutDirection == .leftToRight ? .LTR : .RTL

            // Find asset via appearance-matching lookup
            let namedImage: CUINamedImage? = catalog.findAsset(
                key: catalogKey,
                matchTypes: matchTypes
            ) { appearanceName -> CUINamedImage? in
                catalog.image(
                    withName: self.name,
                    scaleFactor: self.scale,
                    deviceIdiom: CUIDeviceIdiom(rawValue: idiom)!,
                    deviceSubtype: CUISubtype(rawValue: UInt(subtype)) ?? .normal,
                    displayGamut: CUIDisplayGamut(rawValue: UInt(self.gamut.rawValue)) ?? .SRGB,
                    layoutDirection: selfCUIDirection,
                    sizeClassHorizontal: CUIUserInterfaceSizeClass(rawValue: Int(self.horizontalSizeClass)) ?? .any,
                    sizeClassVertical: CUIUserInterfaceSizeClass(rawValue: Int(self.verticalSizeClass)) ?? .any,
                    appearanceName: appearanceName,
                    locale: self.locale.identifier
                )
            }

            guard let namedImage else { return nil }

            // Extract image contents
            let contents: GraphicsImage.Contents
            let unrotatedPixelSize: CGSize

            // TODO: Vector image path (Semantics v3 + preservedVectorRepresentation + VectorImageLayer)
            // When linked on or after v3, if namedImage.preservedVectorRepresentation is true,
            // attempt to get a CUINamedVectorImage from the catalog and wrap it in a
            // VectorImageLayer. Falls through to CGImage path on failure.

            // CGImage path
            guard let cgImage = namedImage.image else { return nil }

            // Prevent weakly-cached catalog from being deallocated while CGImage exists
            if let (cat, retain) = NamedImage.sharedCache[bundle], retain {
                CGImageSetProperty(
                    cgImage,
                    "com.apple.SwiftUI.ObjectToRetain" as CFString,
                    Unmanaged.passUnretained(cat).toOpaque()
                )
            }

            contents = .cgImage(cgImage)
            unrotatedPixelSize = CGSize(
                width: CGFloat(cgImage.width),
                height: CGFloat(cgImage.height)
            )

            // Template rendering mode
            let renderingMode: Image.TemplateRenderingMode?
            switch namedImage.templateRenderingMode {
            case .original:
                renderingMode = .original
            case .template:
                renderingMode = .template
            default:
                renderingMode = nil
            }

            // Orientation from EXIF value
            var orientation = Image.Orientation(exifValue: Int(namedImage.exifOrientation) & 0xF) ?? .up

            // RTL flipping: if image is flippable and its direction doesn't match
            // the requested direction, flip by XOR-ing the orientation raw value
            let cuiDirection = namedImage.layoutDirection
            if namedImage.isFlippable, cuiDirection != .unspecified, cuiDirection != selfCUIDirection {
                orientation = Image.Orientation(rawValue: orientation.rawValue ^ 1)!
            }

            // Scale
            let imageScale = namedImage.scale

            // Resizing info from 9-slice data
            let resizingInfo: Image.ResizingInfo?
            if namedImage.hasSliceInformation {
                let insets = namedImage.edgeInsets
                let edgeInsets = EdgeInsets(
                    top: insets.top,
                    leading: insets.left,
                    bottom: insets.bottom,
                    trailing: insets.right
                )
                let mode: Image.ResizingMode = namedImage.resizingMode == .tiles ? .tile : .stretch
                resizingInfo = Image.ResizingInfo(capInsets: edgeInsets, mode: mode)
            } else {
                resizingInfo = nil
            }

            return BitmapInfo(
                contents: contents,
                scale: imageScale,
                orientation: orientation,
                unrotatedPixelSize: unrotatedPixelSize,
                renderingMode: renderingMode,
                resizingInfo: resizingInfo
            )
        }
        #endif
    }

    // MARK: - NamedImage.BitmapInfo

    package struct BitmapInfo {
        package var contents: GraphicsImage.Contents

        package var scale: CGFloat

        package var orientation: Image.Orientation

        package var unrotatedPixelSize: CGSize

        package var renderingMode: Image.TemplateRenderingMode?

        package var resizingInfo: Image.ResizingInfo?

        package init(
            contents: GraphicsImage.Contents,
            scale: CGFloat,
            orientation: Image.Orientation,
            unrotatedPixelSize: CGSize,
            renderingMode: Image.TemplateRenderingMode?,
            resizingInfo: Image.ResizingInfo?
        ) {
            self.contents = contents
            self.scale = scale
            self.orientation = orientation
            self.unrotatedPixelSize = unrotatedPixelSize
            self.renderingMode = renderingMode
            self.resizingInfo = resizingInfo
        }
    }

    // MARK: - NamedImage.DecodedInfo

    package struct DecodedInfo {
        package var contents: GraphicsImage.Contents

        package var scale: CGFloat

        package var unrotatedPixelSize: CGSize

        package var orientation: Image.Orientation
    }

    // MARK: - NamedImage.Key

    package enum Key: Equatable {
        case bitmap(BitmapKey)
        case uuid(UUID)
    }

    // MARK: - NamedImage.Errors

    package enum Errors: Error, Equatable, Hashable {
        case missingCatalogImage
        case missingUUIDImage
    }

    // MARK: - NamedImage.Cache

    package struct Cache {
        private struct ImageCacheData {
            var vectors: [NamedImage.VectorKey: NamedImage.VectorInfo] = [:]
            var bitmaps: [NamedImage.BitmapKey: NamedImage.BitmapInfo] = [:]
            var uuids: [UUID: NamedImage.DecodedInfo] = [:]
            var catalogs: [URL: WeakCatalog] = [:]
        }

        private struct WeakCatalog {
            #if OPENSWIFTUI_LINK_COREUI
            weak var catalog: CUICatalog?
            #endif
        }

        package var archiveDelegate: AnyArchivedViewDelegate?

        @AtomicBox
        private var data: ImageCacheData = .init()

        package init(archiveDelegate: AnyArchivedViewDelegate? = nil) {
            self.archiveDelegate = archiveDelegate
        }

        // MARK: Cache subscripts

        #if OPENSWIFTUI_LINK_COREUI
        // Looks up cached VectorInfo for key; if not found or catalog changed,
        // calls loadVectorInfo and caches the result.
        private subscript(key: VectorKey, catalog: CUICatalog) -> VectorInfo? {
            let cached = data.vectors[key]
            if let cached {
                if let cachedCatalog = cached.catalog, cachedCatalog == catalog {
                    return cached
                }
            }
            guard let info = key.loadVectorInfo(from: catalog, idiom: key.idiom) else {
                return nil
            }
            data.vectors[key] = info
            return info
        }
        #endif

        // Looks up cached BitmapInfo for key; if not found,
        // calls loadBitmapInfo and caches the result.
        package subscript(key: BitmapKey, location: Image.Location) -> BitmapInfo? {
            #if OPENSWIFTUI_LINK_COREUI
            if let cached = data.bitmaps[key] {
                return cached
            }
            guard let info = key.loadBitmapInfo(location: location, idiom: key.idiom, subtype: key.subtype) else {
                return nil
            }
            data.bitmaps[key] = info
            return info
            #else
            _openSwiftUIPlatformUnimplementedWarning()
            return nil
            #endif
        }

        #if OPENSWIFTUI_LINK_COREUI
        // Resolves a CUICatalog for the given bundle.
        // First tries defaultUICatalog; falls back to Assets.car with weak caching.
        package subscript(bundle: Bundle) -> (CUICatalog, retain: Bool)? {
            if let catalog = CUICatalog.defaultUICatalog(for: bundle) {
                return (catalog, retain: false)
            }
            guard let url = bundle.url(forResource: "Assets", withExtension: "car") else {
                return nil
            }
            if let weakCatalog = data.catalogs[url], let catalog = weakCatalog.catalog {
                return (catalog, retain: true)
            }
            // Clean up stale entries where weak ref is nil
            data.catalogs = data.catalogs.filter { $0.value.catalog != nil }
            guard let catalog = try? CUICatalog(url: url) else {
                return nil
            }
            data.catalogs[url] = WeakCatalog(catalog: catalog)
            return (catalog, retain: true)
        }

        #endif

        package func decode(_ key: Key) throws -> DecodedInfo {
            switch key {
            case .bitmap(let bitmapKey):
                guard let info = self[bitmapKey, bitmapKey.location] else {
                    throw Errors.missingCatalogImage
                }
                return DecodedInfo(
                    contents: info.contents,
                    scale: info.scale,
                    unrotatedPixelSize: info.unrotatedPixelSize,
                    orientation: info.orientation
                )
            case .uuid(let uuid):
                if let cached = data.uuids[uuid] {
                    return cached
                }
                guard let delegate = archiveDelegate else {
                    throw Errors.missingUUIDImage
                }
                let resolved = try delegate.resolveImage(uuid: uuid)
                let cgImage = resolved.cgImage
                let width = CGFloat(cgImage.width)
                let height = CGFloat(cgImage.height)
                let decoded = DecodedInfo(
                    contents: .cgImage(cgImage),
                    scale: resolved.scale,
                    unrotatedPixelSize: CGSize(width: width, height: height),
                    orientation: resolved.orientation
                )
                data.uuids[uuid] = decoded
                return decoded
            }
        }
    }

    // MARK: - NamedImage.sharedCache

    package static var sharedCache = Cache()
}

@available(OpenSwiftUI_v1_0, *)
extension Image {
    public static var _mainNamedBundle: Bundle? { nil }
}

// MARK: - Image.Location

@available(OpenSwiftUI_v1_0, *)
extension Image {
    package enum Location: Equatable, Hashable {
        case bundle(Bundle)
        case system
        case privateSystem

        package var supportsNonVectorImages: Bool {
            guard case .bundle = self else {
                return false
            }
            return true
        }

        #if OPENSWIFTUI_LINK_COREUI
        package var catalog: CUICatalog? {
            switch self {
            case .system:
                return Self.systemAssetManager.catalog
            case .privateSystem:
                return Self.privateSystemAssetManager.catalog
            case .bundle(let bundle):
                return NamedImage.sharedCache[bundle]?.0
            }
        }
        #endif

        package var bundle: Bundle? {
            guard case .bundle(let bundle) = self else {
                return nil
            }
            return bundle
        }

        package func fillVariant(_ variants: SymbolVariants, name: String) -> String? {
            guard variants.contains(.fill) else { return nil }
            switch self {
            case .system:
                return Self.systemAssetManager.fillMapping[name]
            case .privateSystem:
                return Self.privateSystemAssetManager.fillMapping[name]
            case .bundle:
                return name + ".fill"
            }
        }

        package func mayContainSymbol(_ name: String) -> Bool {
            switch self {
            case .system:
                return Self.systemAssetManager.symbols.contains(name)
            case .privateSystem:
                return Self.privateSystemAssetManager.symbols.contains(name)
            case .bundle:
                return true
            }
        }

        private func aliasedName(_ name: String) -> String {
            switch self {
            case .system:
                return Self.systemAssetManager.nameAliases[name] ?? name
            case .privateSystem:
                return Self.privateSystemAssetManager.nameAliases[name] ?? name
            case .bundle:
                return name
            }
        }

        package func findShapeAndFillVariantName<T>(_ variants: SymbolVariants, base: String, body: (String) -> T?) -> T? {
            if let shapeName = variants.shapeVariantName(name: base) {
                let aliasedShape = aliasedName(shapeName)
                if let fillName = fillVariant(variants, name: aliasedShape) {
                    if let result = body(fillName) { return result }
                }
                if let result = body(aliasedShape) { return result }
            }
            let aliasedBase = aliasedName(base)
            if let fillName = fillVariant(variants, name: aliasedBase) {
                if let result = body(fillName) { return result }
            }
            return body(aliasedBase)
        }

        package func findName<T>(_ variants: SymbolVariants, base: String, body: (String) -> T?) -> T? {
            let normalizedVariants = variants._normalizedForNameLookup()
            if normalizedVariants.contains(.slash) {
                let slashName = base + ".slash"
                if let result = findShapeAndFillVariantName(normalizedVariants, base: slashName, body: body) {
                    return result
                }
                return findShapeAndFillVariantName(normalizedVariants, base: base, body: body)
            } else {
                return findShapeAndFillVariantName(normalizedVariants, base: base, body: body)
            }
        }

        package static let systemAssetManager = SystemAssetManager(internalUse: false)

        package static let privateSystemAssetManager = SystemAssetManager(internalUse: true)

        package struct SystemAssetManager {
            #if OPENSWIFTUI_LINK_COREUI
            let catalog: CUICatalog
            #endif
            let fillMapping: [String: String]
            let nameAliases: [String: String]
            let symbols: [String]

            package init(internalUse: Bool) {
                let bundlePath: String
                if internalUse {
                    // TODO: Load from SFSymbols private framework
                    // fillMapping = SFSymbols.private_nofill_to_fill
                    // nameAliases = SFSymbols.private_name_aliases
                    // symbols = SFSymbols.private_symbol_order
                    fillMapping = [:]
                    nameAliases = [:]
                    symbols = []
                    bundlePath = "/System/Library/CoreServices/CoreGlyphsPrivate.bundle"
                } else {
                    // TODO: Load from SFSymbols framework
                    // fillMapping = SFSymbols.nofill_to_fill
                    // nameAliases = SFSymbols.name_aliases
                    // symbols = SFSymbols.symbol_order
                    fillMapping = [:]
                    nameAliases = [:]
                    symbols = []
                    bundlePath = "/System/Library/CoreServices/CoreGlyphs.bundle"
                }
                #if OPENSWIFTUI_LINK_COREUI
                let fullPath = _SimulatorSystemRootDirectory() + bundlePath
                let bundle = Bundle(path: fullPath)!
                catalog = try! CUICatalog(name: "Assets", from: bundle, error: ())
                #endif
            }
        }
    }

    // MARK: - Image named initializers

    /// Creates a labeled image that you can use as content for controls.
    ///
    /// - Parameters:
    ///   - name: The name of the image resource to lookup, as well as the
    ///     localization key with which to label the image.
    ///   - bundle: The bundle to search for the image resource and localization
    ///     content. If `nil`, OpenSwiftUI uses the main `Bundle`. Defaults to `nil`.
    public init(_ name: String, bundle: Bundle? = nil) {
        self.init(
            NamedImageProvider(
                name: name,
                location: .bundle(bundle ?? Bundle.main),
                label: AccessibilityImageLabel(Text(LocalizedStringKey(name), bundle: bundle)),
                decorative: false
            )
        )
    }

    /// Creates a labeled image that you can use as content for controls, with
    /// the specified label.
    ///
    /// - Parameters:
    ///   - name: The name of the image resource to lookup
    ///   - bundle: The bundle to search for the image resource. If `nil`,
    ///     OpenSwiftUI uses the main `Bundle`. Defaults to `nil`.
    ///   - label: The label associated with the image. OpenSwiftUI uses the label
    ///     for accessibility.
    public init(_ name: String, bundle: Bundle? = nil, label: Text) {
        self.init(
            NamedImageProvider(
                name: name,
                location: .bundle(bundle ?? Bundle.main),
                label: AccessibilityImageLabel(label),
                decorative: false
            )
        )
    }

    /// Creates an unlabeled, decorative image.
    ///
    /// OpenSwiftUI ignores this image for accessibility purposes.
    ///
    /// - Parameters:
    ///   - name: The name of the image resource to lookup
    ///   - bundle: The bundle to search for the image resource. If `nil`,
    ///     OpenSwiftUI uses the main `Bundle`. Defaults to `nil`.
    public init(decorative name: String, bundle: Bundle? = nil) {
        self.init(
            NamedImageProvider(
                name: name,
                location: .bundle(bundle ?? Bundle.main),
                label: nil,
                decorative: true
            )
        )
    }

    /// Creates a system symbol image.
    ///
    /// This initializer creates an image using a system-provided symbol. Use
    /// [SF Symbols](https://developer.apple.com/design/resources/#sf-symbols)
    /// to find symbols and their corresponding names.
    ///
    /// To create a custom symbol image from your app's asset catalog, use
    /// ``Image/init(_:bundle:)`` instead.
    ///
    /// - Parameters:
    ///   - systemName: The name of the system symbol image.
    ///     Use the SF Symbols app to look up the names of system symbol images.
    @available(macOS, introduced: 11.0)
    public init(systemName: String) {
        self.init(
            NamedImageProvider(
                name: systemName,
                location: .system,
                label: .systemSymbol(systemName),
                decorative: false
            )
        )
    }

    /// SPI for internal clients to access internal system symbols.
    @available(OpenSwiftUI_v1_0, *)
    public init(_internalSystemName systemName: String) {
        self.init(
            NamedImageProvider(
                name: systemName,
                location: .privateSystem,
                label: .systemSymbol(systemName),
                decorative: false,
                backupLocation: .system
            )
        )
    }

    // MARK: - Image.NamedImageProvider

    package struct NamedImageProvider: ImageProvider {
        package var name: String

        package var value: Float?

        package var location: Image.Location

        package var backupLocation: Image.Location?

        package var label: AccessibilityImageLabel?

        package var decorative: Bool

        package init(
            name: String,
            value: Float? = nil,
            location: Image.Location,
            label: AccessibilityImageLabel?,
            decorative: Bool,
            backupLocation: Image.Location? = nil
        ) {
            self.name = name
            self.value = value
            self.location = location
            self.label = label
            self.decorative = decorative
            self.backupLocation = backupLocation
        }

        package func resolve(in context: ImageResolutionContext) -> Image.Resolved {
            // TODO: Full CoreUI-based resolution
            // The real implementation:
            // 1. Tries vector resolution first (via vectorInfo)
            // 2. Falls back to bitmap resolution (via bitmapInfo)
            // 3. Returns resolveError if both fail
            resolveError(in: context.environment)
        }

        package func resolveError(in environment: EnvironmentValues) -> Image.Resolved {
            Image.Resolved(
                image: GraphicsImage(
                    contents: nil,
                    scale: environment.displayScale,
                    unrotatedPixelSize: .zero,
                    orientation: .up,
                    isTemplate: false
                ),
                decorative: decorative,
                label: label
            )
        }

        package func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
            let environment = context.environment
            let isTemplate = environment.imageIsTemplate()
            return Image.NamedResolved(
                name: name,
                location: location,
                value: value,
                symbolRenderingMode: context.symbolRenderingMode?.storage,
                isTemplate: isTemplate,
                environment: environment
            )
        }
    }
}

// MARK: - Image named initializers with variableValue

@available(OpenSwiftUI_v4_0, *)
extension Image {

    /// Creates a system symbol image with a variable value.
    ///
    /// This initializer creates an image using a system-provided symbol. The
    /// rendered symbol may alter its appearance to represent the value
    /// provided in `variableValue`. Use
    /// [SF Symbols](https://developer.apple.com/design/resources/#sf-symbols)
    /// (version 4.0 or later) to find system symbols that support variable
    /// values and their corresponding names.
    ///
    /// The following example shows the effect of creating the `"chart.bar.fill"`
    /// symbol with different values.
    ///
    ///     HStack{
    ///         Image(systemName: "chart.bar.fill", variableValue: 0.3)
    ///         Image(systemName: "chart.bar.fill", variableValue: 0.6)
    ///         Image(systemName: "chart.bar.fill", variableValue: 1.0)
    ///     }
    ///     .font(.system(.largeTitle))
    ///
    /// ![Three instances of the bar chart symbol, arranged horizontally.
    /// The first fills one bar, the second fills two bars, and the last
    /// symbol fills all three bars.](Image-3)
    ///
    /// To create a custom symbol image from your app's asset
    /// catalog, use ``Image/init(_:variableValue:bundle:)`` instead.
    ///
    /// - Parameters:
    ///   - systemName: The name of the system symbol image.
    ///     Use the SF Symbols app to look up the names of system
    ///     symbol images.
    ///   - variableValue: An optional value between `0.0` and `1.0` that
    ///     the rendered image can use to customize its appearance, if
    ///     specified. If the symbol doesn't support variable values, this
    ///     parameter has no effect. Use the SF Symbols app to look up which
    ///     symbols support variable values.
    public init(systemName: String, variableValue: Double?) {
        self.init(
            NamedImageProvider(
                name: systemName,
                value: variableValue.map { Float($0) },
                location: .system,
                label: .systemSymbol(systemName),
                decorative: false
            )
        )
    }

    /// SPI for internal clients to access internal system symbols.
    public init(_internalSystemName systemName: String, variableValue: Double?) {
        self.init(
            NamedImageProvider(
                name: systemName,
                value: variableValue.map { Float($0) },
                location: .privateSystem,
                label: .systemSymbol(systemName),
                decorative: false,
                backupLocation: .system
            )
        )
    }

    /// Creates a labeled image that you can use as content for controls,
    /// with a variable value.
    ///
    /// This initializer creates an image using a using a symbol in the
    /// specified bundle. The rendered symbol may alter its appearance to
    /// represent the value provided in `variableValue`.
    ///
    /// > Note: See WWDC22 session [10158: Adopt variable color in SF
    /// Symbols](https://developer.apple.com/wwdc22/10158/) for details
    /// on how to create symbols that support variable values.
    ///
    /// - Parameters:
    ///   - name: The name of the image resource to lookup, as well as
    ///     the localization key with which to label the image.
    ///   - variableValue: An optional value between `0.0` and `1.0` that
    ///     the rendered image can use to customize its appearance, if
    ///     specified. If the symbol doesn't support variable values, this
    ///     parameter has no effect.
    ///   - bundle: The bundle to search for the image resource and
    ///     localization content. If `nil`, OpenSwiftUI uses the main
    ///     `Bundle`. Defaults to `nil`.
    ///
    public init(_ name: String, variableValue: Double?, bundle: Bundle? = nil) {
        self.init(
            NamedImageProvider(
                name: name,
                value: variableValue.map { Float($0) },
                location: .bundle(bundle ?? Bundle.main),
                label: AccessibilityImageLabel(Text(LocalizedStringKey(name), bundle: bundle)),
                decorative: false
            )
        )
    }

    /// Creates a labeled image that you can use as content for controls, with
    /// the specified label and variable value.
    ///
    /// This initializer creates an image using a using a symbol in the
    /// specified bundle. The rendered symbol may alter its appearance to
    /// represent the value provided in `variableValue`.
    ///
    /// > Note: See WWDC22 session [10158: Adopt variable color in SF
    /// Symbols](https://developer.apple.com/wwdc22/10158/) for details on
    /// how to create symbols that support variable values.
    ///
    /// - Parameters:
    ///   - name: The name of the image resource to lookup.
    ///   - variableValue: An optional value between `0.0` and `1.0` that
    ///     the rendered image can use to customize its appearance, if
    ///     specified. If the symbol doesn't support variable values, this
    ///     parameter has no effect.
    ///   - bundle: The bundle to search for the image resource. If
    ///     `nil`, OpenSwiftUI uses the main `Bundle`. Defaults to `nil`.
    ///   - label: The label associated with the image. OpenSwiftUI uses
    ///     the label for accessibility.
    ///
    public init(_ name: String, variableValue: Double?, bundle: Bundle? = nil, label: Text) {
        self.init(
            NamedImageProvider(
                name: name,
                value: variableValue.map { Float($0) },
                location: .bundle(bundle ?? Bundle.main),
                label: AccessibilityImageLabel(label),
                decorative: false
            )
        )
    }

    /// Creates an unlabeled, decorative image, with a variable value.
    ///
    /// This initializer creates an image using a using a symbol in the
    /// specified bundle. The rendered symbol may alter its appearance to
    /// represent the value provided in `variableValue`.
    ///
    /// > Note: See WWDC22 session [10158: Adopt variable color in SF
    /// Symbols](https://developer.apple.com/wwdc22/10158/) for details on
    /// how to create symbols that support variable values.
    ///
    /// OpenSwiftUI ignores this image for accessibility purposes.
    ///
    /// - Parameters:
    ///   - name: The name of the image resource to lookup.
    ///   - variableValue: An optional value between `0.0` and `1.0` that
    ///     the rendered image can use to customize its appearance, if
    ///     specified. If the symbol doesn't support variable values, this
    ///     parameter has no effect.
    ///   - bundle: The bundle to search for the image resource. If
    ///     `nil`, OpenSwiftUI uses the main `Bundle`. Defaults to `nil`.
    ///
    public init(decorative name: String, variableValue: Double?, bundle: Bundle? = nil) {
        self.init(
            NamedImageProvider(
                name: name,
                value: variableValue.map { Float($0) },
                location: .bundle(bundle ?? Bundle.main),
                label: nil,
                decorative: true
            )
        )
    }
}

// MARK: - Image.Location + ProtobufMessage

extension Image.Location: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        switch self {
        case .bundle(let bundle):
            encoder.intField(1, 2)
            try encoder.stringField(2, bundle.bundlePath)
        case .system:
            encoder.intField(1, 0)
        case .privateSystem:
            encoder.intField(1, 1)
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var discriminator: Int = 0
        var path: String?
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: discriminator = try decoder.intField(field)
            case 2: path = try decoder.stringField(field)
            default: try decoder.skipField(field)
            }
        }
        switch discriminator {
        case 0: self = .system
        case 1: self = .privateSystem
        case 2:
            if let path, let bundle = Bundle(path: path) {
                self = .bundle(bundle)
            } else {
                self = .system
            }
        default: self = .system
        }
    }
}

// MARK: - Image.HashableScale [WIP]

extension Image {
    /// A hashable representation of `Image.Scale` for use as a cache key.
    package enum HashableScale: Hashable {
        case small
        case medium
        case large
        case ccSmall
        case ccMedium
        case ccLarge

        package init(_ scale: Image.Scale) {
            switch scale {
            case .small: self = .small
            case .medium: self = .medium
            case .large: self = .large
            case ._controlCenter_small: self = .ccSmall
            case ._controlCenter_medium: self = .ccMedium
            case ._controlCenter_large: self = .ccLarge
            default: self = .medium
            }
        }

        // MARK: - Helpers for symbol sizing

        /// Maps image scale to CUI glyph size: small→1, medium→2, large→3.
        fileprivate var glyphSize: Int {
            switch self {
            case .small, .ccSmall: return 1
            case .medium, .ccMedium: return 2
            case .large, .ccLarge: return 3
            }
        }

        /// Returns the allowed range for symbol size scaling.
        ///
        /// - For standard scales (small, medium, large): returns 1.0...1.0 (no scaling)
        /// - For control center scales: reads from NSUserDefaults
        ///   "CCImageScale_MinimumScale" and "CCImageScale_MaximumScale"
        package var allowedScaleRange: ClosedRange<CGFloat> {
            switch self {
            case .small, .medium, .large:
                return 1.0 ... 1.0
            case .ccSmall, .ccMedium, .ccLarge:
                #if canImport(Darwin)
                let defaults = UserDefaults.standard
                let lower = (defaults.value(forKey: "CCImageScale_MinimumScale") as? CGFloat) ?? 0.0
                let upper = (defaults.value(forKey: "CCImageScale_MaximumScale") as? CGFloat) ?? .greatestFiniteMagnitude
                precondition(lower <= upper, "xx")
                return lower ... upper
                #else
                return 0.0 ... .greatestFiniteMagnitude
                #endif
            }
        }

        // Weight interpolation constants per scale category:
        //   (lightValue, nominalValue, heavyValue)
        // where lightValue is at weight -0.8 (ultraLight),
        //       nominalValue is at weight 0 (regular),
        //       heavyValue is at weight 0.62 (black).
        //
        // These represent the circle.fill diameter as a percentage of point size.
        private static let smallConstants:  (light: Double, nominal: Double, heavy: Double) = (74.46, 78.86, 83.98)
        private static let mediumConstants: (light: Double, nominal: Double, heavy: Double) = (94.63, 99.61, 106.64)
        private static let largeConstants:  (light: Double, nominal: Double, heavy: Double) = (121.66, 127.2, 135.89)

        /// Computes the diameter of a circle.fill symbol for the given point size and weight.
        ///
        /// The result is `interpolatedPercentage * 0.01 * pointSize`, where the
        /// percentage is interpolated based on font weight between three known
        /// values (ultraLight, regular, black).
        package func circleDotFillSize(pointSize: CGFloat, weight: Font.Weight) -> CGFloat {
            let w = weight.value
            let constants: (light: Double, nominal: Double, heavy: Double)

            // Discriminator bitmask: medium/ccMedium = 0x52, small/ccSmall = 0x9
            switch self {
            case .medium, .ccMedium:
                constants = Self.mediumConstants
            case .small, .ccSmall:
                constants = Self.smallConstants
            default: // large, ccLarge
                constants = Self.largeConstants
            }

            let percentage: CGFloat
            if w == 0.0 {
                percentage = constants.nominal
            } else if w < 0.0 {
                // Interpolate from light (at -0.8) to nominal (at 0)
                percentage = constants.light + (w + 0.8) / 0.8 * (constants.nominal - constants.light)
            } else {
                // Interpolate from nominal (at 0) to heavy (at 0.62)
                percentage = constants.nominal + w / 0.62 * (constants.heavy - constants.nominal)
            }

            return percentage * 0.01 * pointSize
        }

        /// Computes the maximum allowed radius from a given diameter.
        ///
        /// The base radius is `diameter / 2`. For control center scales,
        /// this is multiplied by a scale factor read from NSUserDefaults
        /// "CCImageScale_CircleScale" (default 1.2).
        package func maxRadius(diameter: CGFloat) -> CGFloat {
            var radius = diameter * 0.5

            switch self {
            case .small, .medium, .large:
                break
            case .ccSmall, .ccMedium, .ccLarge:
                #if canImport(Darwin)
                let scale = (UserDefaults.standard.value(forKey: "CCImageScale_CircleScale") as? CGFloat) ?? 1.2
                #else
                let scale: CGFloat = 1.2
                #endif
                radius *= scale
            }

            return radius
        }
    }
}

// MARK: - Image.ResolvedUUID [WIP]

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension Image {

    public struct ResolvedUUID {
        package var cgImage: CGImage
        package var scale: CGFloat
        package var orientation: Image.Orientation

        package init(cgImage: CGImage, scale: CGFloat, orientation: Image.Orientation) {
            self.cgImage = cgImage
            self.scale = scale
            self.orientation = orientation
        }
    }
}

@_spi(Private)
@available(*, unavailable)
extension Image.ResolvedUUID: Sendable {}

// MARK: - NamedImage.Key + ProtobufMessage

extension NamedImage.Key: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        switch self {
        case .bitmap(let bitmapKey):
            try encoder.messageField(1, bitmapKey)
        case .uuid:
            // TODO: UUID protobuf encoding
            break
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var result: NamedImage.Key?
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                result = .bitmap(try decoder.messageField(field))
            default:
                try decoder.skipField(field)
            }
        }
        guard let result else {
            throw ProtobufDecoder.DecodingError.failed
        }
        self = result
    }
}

// MARK: - NamedImage.BitmapKey + ProtobufMessage

extension NamedImage.BitmapKey: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, catalogKey)
        try encoder.stringField(2, name)
        encoder.cgFloatField(3, scale)
        try encoder.messageField(4, location)
        encoder.intField(5, layoutDirection == .rightToLeft ? 1 : 0)
        // locale encoding omitted - Locale does not yet conform to ProtobufMessage
        encoder.intField(7, gamut.rawValue)
        encoder.intField(8, idiom)
        encoder.intField(9, subtype)
        encoder.intField(10, Int(horizontalSizeClass))
        encoder.intField(11, Int(verticalSizeClass))
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var catalogKey = CatalogKey(colorScheme: .light, contrast: .standard)
        var name = ""
        var scale: CGFloat = 0
        var location: Image.Location = .system
        var layoutDirection: LayoutDirection = .leftToRight
        var gamut: DisplayGamut = .sRGB
        var idiom: Int = 0
        var subtype: Int = 0
        var horizontalSizeClass: Int8 = 0
        var verticalSizeClass: Int8 = 0

        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: catalogKey = try decoder.messageField(field)
            case 2: name = try decoder.stringField(field)
            case 3: scale = try decoder.cgFloatField(field)
            case 4: location = try decoder.messageField(field)
            case 5:
                let value: Int = try decoder.intField(field)
                layoutDirection = value == 1 ? .rightToLeft : .leftToRight
            case 7:
                let value: Int = try decoder.intField(field)
                gamut = DisplayGamut(rawValue: value) ?? .sRGB
            case 8: idiom = try decoder.intField(field)
            case 9: subtype = try decoder.intField(field)
            case 10: horizontalSizeClass = Int8(try decoder.intField(field) as Int)
            case 11: verticalSizeClass = Int8(try decoder.intField(field) as Int)
            default: try decoder.skipField(field)
            }
        }
        self.init(
            catalogKey: catalogKey,
            name: name,
            scale: scale,
            location: location,
            layoutDirection: layoutDirection,
            locale: .autoupdatingCurrent,
            gamut: gamut,
            idiom: idiom,
            subtype: subtype,
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }
}

// MARK: - CUI Helpers

#if OPENSWIFTUI_LINK_COREUI

extension Font.Weight {
    /// Maps Font.Weight to CUI's `_CUIThemeVectorGlyphWeight` values.
    ///
    /// Matches each known weight value (within 0.001 tolerance):
    /// - ultraLight (-0.8) → 1
    /// - thin (-0.6) → 2
    /// - light (-0.4) → 3
    /// - regular (0.0) → 4
    /// - medium (0.23) → 5
    /// - semibold (0.3) → 6
    /// - bold (0.4) → 7
    /// - heavy (0.56) → 8
    /// - black (0.62) → 9
    /// - unknown → 4 (regular)
    fileprivate var glyphWeight: _CUIThemeVectorGlyphWeight {
        let v = value
        let tolerance = 0.001
        if abs(v - (-0.8)) < tolerance { return .ultraLight }
        if abs(v - (-0.6)) < tolerance { return .thin }
        if abs(v - (-0.4)) < tolerance { return .light }
        if abs(v - 0.0) < tolerance { return .regular }
        if abs(v - 0.23) < tolerance { return .medium }
        if abs(v - 0.3) < tolerance { return .semibold }
        if abs(v - 0.4) < tolerance { return .bold }
        if abs(v - 0.56) < tolerance { return .heavy }
        if abs(v - 0.62) < tolerance { return .black }
        return .regular
    }

    /// Maps Font.Weight to CUI's continuous weight CGFloat value.
    ///
    /// Looks up the `_CUIThemeVectorGlyphWeight`, then returns the corresponding
    /// `_CUIVectorGlyphContinuousWeight*` constant from CoreUI.
    fileprivate var glyphContinuousWeight: CGFloat {
        switch glyphWeight {
        case .ultraLight: return _CUIVectorGlyphContinuousWeightUltralight
        case .thin: return _CUIVectorGlyphContinuousWeightThin
        case .light: return _CUIVectorGlyphContinuousWeightLight
        case .regular: return _CUIVectorGlyphContinuousWeightRegular
        case .medium: return _CUIVectorGlyphContinuousWeightMedium
        case .semibold: return _CUIVectorGlyphContinuousWeightSemibold
        case .bold: return _CUIVectorGlyphContinuousWeightBold
        case .heavy: return _CUIVectorGlyphContinuousWeightHeavy
        case .black: return _CUIVectorGlyphContinuousWeightBlack
        @unknown default: return _CUIVectorGlyphContinuousWeightRegular
        }
    }
}

extension LayoutDirection {
    /// Converts SwiftUI LayoutDirection to CUI's layout direction.
    fileprivate var cuiLayoutDirection: CUILayoutDirection {
        switch self {
        case .leftToRight: return .LTR
        case .rightToLeft: return .RTL
        }
    }
}

#endif

#if canImport(Darwin) && canImport(DeveloperToolsSupport)

public import DeveloperToolsSupport

// MARK: - Image + ImageResource [TODO]

extension Image {
    /// Initialize a `Image` with a image resource.
    public init(_ resource: ImageResource) {
        _openSwiftUIUnimplementedFailure()
    }
}
#endif
