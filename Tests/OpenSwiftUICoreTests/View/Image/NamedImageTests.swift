//
//  NamedImageTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenCoreGraphicsShims
@_spi(Private)
@testable
#if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
@_private(sourceFile: "NamedImage.swift")
#endif
import OpenSwiftUICore
import Testing

// MARK: - NamedImage.Errors Tests

struct NamedImageErrorsTests {
    @Test
    func conformsToError() {
        let error: any Error = NamedImage.Errors.missingCatalogImage
        #expect(error is NamedImage.Errors)
    }
}

// MARK: - NamedImage.Key Tests

struct NamedImageKeyTests {
    @Test
    func bitmapKeyInitFromEnvironment() {
        var env = EnvironmentValues()
        env.displayScale = 3.0
        env.layoutDirection = .rightToLeft
        env.displayGamut = .displayP3
        let key = NamedImage.BitmapKey(
            name: "icon",
            location: .bundle(.main),
            in: env
        )
        #expect(key.name == "icon")
        #expect(key.scale == 3.0)
        #expect(key.layoutDirection == .rightToLeft)
        #expect(key.gamut == .displayP3)
    }

    @Test
    func bitmapKeySizeClassConversion() {
        var env = EnvironmentValues()
        // Default: nil -> 0
        let key1 = NamedImage.BitmapKey(name: "a", location: .system, in: env)
        #expect(key1.horizontalSizeClass == 0)
        #expect(key1.verticalSizeClass == 0)

        // .compact -> 1
        env.horizontalSizeClass = .compact
        let key2 = NamedImage.BitmapKey(name: "a", location: .system, in: env)
        #expect(key2.horizontalSizeClass == 1)

        // .regular -> 2
        env.horizontalSizeClass = .regular
        env.verticalSizeClass = .regular
        let key3 = NamedImage.BitmapKey(name: "a", location: .system, in: env)
        #expect(key3.horizontalSizeClass == 2)
        #expect(key3.verticalSizeClass == 2)
    }
}

// MARK: - Image.Location Tests

struct ImageLocationTests {
    @Test
    func supportsNonVectorImages() {
        #expect(Image.Location.bundle(.main).supportsNonVectorImages == true)
        #expect(Image.Location.system.supportsNonVectorImages == false)
        #expect(Image.Location.privateSystem.supportsNonVectorImages == false)
    }

    @Test
    func bundleAccessor() {
        let bundle = Bundle.main
        #expect(Image.Location.bundle(bundle).bundle === bundle)
        #expect(Image.Location.system.bundle == nil)
        #expect(Image.Location.privateSystem.bundle == nil)
    }

    @Test
    func fillVariantBundleAppendsFill() {
        let location = Image.Location.bundle(.main)
        let result = location.fillVariant(.fill, name: "star")
        #expect(result == "star.fill")
    }

    @Test
    func fillVariantReturnsNilWithoutFill() {
        let location = Image.Location.bundle(.main)
        let result = location.fillVariant(.none, name: "star")
        #expect(result == nil)
    }

    @Test
    func mayContainSymbolBundleAlwaysTrue() {
        let location = Image.Location.bundle(.main)
        #expect(location.mayContainSymbol("anything") == true)
        #expect(location.mayContainSymbol("") == true)
    }

    @Test
    func findNamePassesCorrectCandidates() {
        let location = Image.Location.bundle(.main)
        var candidates: [String] = []

        // With no variants, should just pass the base name
        let _: String? = location.findName(.none, base: "star") { name in
            candidates.append(name)
            return nil
        }
        #expect(candidates == ["star"])
    }

    @Test
    func findNameWithFillVariant() {
        let location = Image.Location.bundle(.main)
        var candidates: [String] = []

        // With .fill variant, should try "star.fill" before "star"
        let _: String? = location.findName(.fill, base: "star") { name in
            candidates.append(name)
            return nil
        }
        #expect(candidates == ["star.fill", "star"])
    }

    @Test
    func findNameReturnsFirstMatch() {
        let location = Image.Location.bundle(.main)

        let result: String? = location.findName(.fill, base: "star") { name in
            name.hasSuffix(".fill") ? name : nil
        }
        #expect(result == "star.fill")
    }
}

// MARK: - Image.HashableScale Tests

struct HashableScaleTests {
    @Test
    func initFromScale() {
        #expect(Image.HashableScale(.small) == .small)
        #expect(Image.HashableScale(.medium) == .medium)
        #expect(Image.HashableScale(.large) == .large)
    }
}

// MARK: - NamedImage.Cache Tests

struct NamedImageCacheTests {
    @Test
    func decodeThrowsMissingCatalogImage() {
        let cache = NamedImage.Cache()
        let bitmapKey = NamedImage.BitmapKey(
            catalogKey: CatalogKey(colorScheme: .light, contrast: .standard),
            name: "missing",
            scale: 1.0,
            location: .system,
            layoutDirection: .leftToRight,
            locale: .autoupdatingCurrent,
            gamut: .sRGB,
            idiom: 0,
            subtype: 0
        )
        let key = NamedImage.Key.bitmap(bitmapKey)
        #expect(throws: NamedImage.Errors.missingCatalogImage) {
            try cache.decode(key)
        }
    }

    @Test
    func decodeThrowsMissingUUIDImage() {
        let cache = NamedImage.Cache()
        let key = NamedImage.Key.uuid(UUID())
        #expect(throws: NamedImage.Errors.missingUUIDImage) {
            try cache.decode(key)
        }
    }

    @Test
    func sharedCacheExists() {
        let cache = NamedImage.sharedCache
        _ = cache // Access should not crash
    }
}

// MARK: - NamedImageProvider Tests

struct NamedImageProviderTests {
    @Test
    func valueProperty() {
        let provider = Image.NamedImageProvider(
            name: "slider",
            value: 0.5,
            location: .system,
            label: nil,
            decorative: false
        )
        #expect(provider.value == 0.5)
    }

    @Test
    func resolveErrorScale() {
        let provider = Image.NamedImageProvider(
            name: "nonexistent",
            location: .system,
            label: nil,
            decorative: true
        )
        let environment = EnvironmentValues()
        let resolved = provider.resolveError(in: environment)
        #expect(resolved.image.scale == 1.0)
        #expect(resolved.image.contents == nil)
        #expect(resolved.decorative == true)
    }

    @Test
    func resolveNamedImageReturnsNilForMissingImage() {
        let provider = Image.NamedImageProvider(
            name: "nonexistent_image_xyz",
            location: .bundle(.main),
            label: nil,
            decorative: false
        )
        let context = ImageResolutionContext(environment: EnvironmentValues())
        let result = provider.resolveNamedImage(in: context)
        #expect(result == nil)
    }

}
