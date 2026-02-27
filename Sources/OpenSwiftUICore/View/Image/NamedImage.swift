//
//  NamedImage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8E7DCD4CEB1ACDE07B249BFF4CBC75C0 (SwiftUICore)

package import Foundation
package import OpenCoreGraphicsShims

#if OPENSWIFTUI_LINK_COREUI
package import CoreUI
#endif

// MARK: - NamedImage

package enum NamedImage {

    // MARK: - NamedImage.VectorKey [WIP]

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

        // TODO: loadVectorInfo

        // [TBA]
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
                return 1.0
            }

            guard let layers = glyph.monochromeLayers as? [CUIVectorGlyphLayer] else {
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

    #if OPENSWIFTUI_LINK_COREUI
    // MARK: - VectorInfo

    package struct VectorInfo {
        package var glyph: CUINamedVectorGlyph

        package var flipsRightToLeft: Bool

        package var layoutMetrics: Image.LayoutMetrics
    }
    #endif

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

        // TODO: loadBitmapInfo
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

    // MARK: - NamedImage.Cache [TODO]

    package struct Cache {
        private struct ImageCacheData {
            var bitmaps: [NamedImage.BitmapKey: NamedImage.BitmapInfo] = [:]
            var uuids: [UUID: NamedImage.DecodedInfo] = [:]
            #if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI
            var catalogs: [URL: WeakCatalog] = [:]
            #endif
        }

        #if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI
        struct WeakCatalog {
            weak var catalog: CUICatalog?
        }
        #endif

        @AtomicBox
        private var _data: ImageCacheData

        package init() {
            self.__data = AtomicBox(wrappedValue: ImageCacheData())
        }

        // MARK: Cache subscripts

        #if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI
        package subscript(key: BitmapKey, location: Image.Location) -> BitmapInfo? {
            // TODO: Full CoreUI bitmap lookup implementation
            get { nil }
        }

        package subscript(bundle: Bundle) -> (CUICatalog, retain: Bool)? {
            // TODO: Full CoreUI catalog lookup implementation
            get { nil }
        }
        #endif

        package func decode(_ key: Key) throws -> DecodedInfo {
            switch key {
            case .bitmap:
                throw Errors.missingCatalogImage
            case .uuid:
                throw Errors.missingUUIDImage
            }
        }
    }

    // MARK: - NamedImage.sharedCache

    private static let _sharedCache = Cache()

    package static var sharedCache: Cache {
        _sharedCache
    }
}

// TODO: WIP

// MARK: - Image.Location

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

        #if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI
        package var catalog: CUICatalog? {
            switch self {
            case .bundle(let bundle):
                return NamedImage.sharedCache[bundle]?.0
            case .system:
                return nil
            case .privateSystem:
                return nil
            }
        }
        #endif

        package var bundle: Bundle? {
            guard case .bundle(let bundle) = self else {
                return nil
            }
            return bundle
        }

        package static func == (a: Image.Location, b: Image.Location) -> Bool {
            switch (a, b) {
            case let (.bundle(lhs), .bundle(rhs)):
                return lhs == rhs
            case (.system, .system):
                return true
            case (.privateSystem, .privateSystem):
                return true
            default:
                return false
            }
        }

        package func hash(into hasher: inout Hasher) {
            switch self {
            case .bundle(let bundle):
                hasher.combine(0)
                hasher.combine(bundle.bundleURL)
            case .system:
                hasher.combine(1)
            case .privateSystem:
                hasher.combine(2)
            }
        }
    }
}

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
