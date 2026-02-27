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
    func equality() {
        let a = NamedImage.Errors.missingCatalogImage
        let b = NamedImage.Errors.missingUUIDImage
        #expect(a == a)
        #expect(b == b)
        #expect(a != b)
    }

    @Test
    func hashing() {
        let a = NamedImage.Errors.missingCatalogImage
        let b = NamedImage.Errors.missingUUIDImage
        #expect(a.hashValue != b.hashValue)
        #expect(a.hashValue == NamedImage.Errors.missingCatalogImage.hashValue)
    }

    @Test
    func conformsToError() {
        let error: any Error = NamedImage.Errors.missingCatalogImage
        #expect(error is NamedImage.Errors)
    }
}

// MARK: - NamedImage.Key Tests

struct NamedImageKeyTests {
    @Test
    func bitmapKeyEquality() {
        let key1 = NamedImage.BitmapKey(
            catalogKey: CatalogKey(colorScheme: .light, contrast: .standard),
            name: "test",
            scale: 2.0,
            location: .system,
            layoutDirection: .leftToRight,
            locale: .autoupdatingCurrent,
            gamut: .sRGB,
            idiom: 0,
            subtype: 0
        )
        let key2 = NamedImage.BitmapKey(
            catalogKey: CatalogKey(colorScheme: .light, contrast: .standard),
            name: "test",
            scale: 2.0,
            location: .system,
            layoutDirection: .leftToRight,
            locale: .autoupdatingCurrent,
            gamut: .sRGB,
            idiom: 0,
            subtype: 0
        )
        #expect(key1 == key2)
    }

    @Test
    func bitmapKeyInequality() {
        let key1 = NamedImage.BitmapKey(
            catalogKey: CatalogKey(colorScheme: .light, contrast: .standard),
            name: "image_a",
            scale: 2.0,
            location: .system,
            layoutDirection: .leftToRight,
            locale: .autoupdatingCurrent,
            gamut: .sRGB,
            idiom: 0,
            subtype: 0
        )
        let key2 = NamedImage.BitmapKey(
            catalogKey: CatalogKey(colorScheme: .light, contrast: .standard),
            name: "image_b",
            scale: 2.0,
            location: .system,
            layoutDirection: .leftToRight,
            locale: .autoupdatingCurrent,
            gamut: .sRGB,
            idiom: 0,
            subtype: 0
        )
        #expect(key1 != key2)
    }

    @Test
    func bitmapKeyHashing() {
        let key1 = NamedImage.BitmapKey(
            catalogKey: CatalogKey(colorScheme: .light, contrast: .standard),
            name: "test",
            scale: 2.0,
            location: .system,
            layoutDirection: .leftToRight,
            locale: .autoupdatingCurrent,
            gamut: .sRGB,
            idiom: 0,
            subtype: 0
        )
        let key2 = NamedImage.BitmapKey(
            catalogKey: CatalogKey(colorScheme: .light, contrast: .standard),
            name: "test",
            scale: 2.0,
            location: .system,
            layoutDirection: .leftToRight,
            locale: .autoupdatingCurrent,
            gamut: .sRGB,
            idiom: 0,
            subtype: 0
        )
        #expect(key1.hashValue == key2.hashValue)
    }

    @Test
    func bitmapKeyDifferentNamesProduceDifferentHashes() {
        let key1 = NamedImage.BitmapKey(
            catalogKey: CatalogKey(colorScheme: .light, contrast: .standard),
            name: "alpha",
            scale: 1.0,
            location: .system,
            layoutDirection: .leftToRight,
            locale: .autoupdatingCurrent,
            gamut: .sRGB,
            idiom: 0,
            subtype: 0
        )
        let key2 = NamedImage.BitmapKey(
            catalogKey: CatalogKey(colorScheme: .light, contrast: .standard),
            name: "beta",
            scale: 1.0,
            location: .system,
            layoutDirection: .leftToRight,
            locale: .autoupdatingCurrent,
            gamut: .sRGB,
            idiom: 0,
            subtype: 0
        )
        #expect(key1.hashValue != key2.hashValue)
    }

    @Test
    func bitmapKeySizeClassDefaults() {
        let key = NamedImage.BitmapKey(
            catalogKey: CatalogKey(colorScheme: .light, contrast: .standard),
            name: "test",
            scale: 1.0,
            location: .system,
            layoutDirection: .leftToRight,
            locale: .autoupdatingCurrent,
            gamut: .sRGB,
            idiom: 0,
            subtype: 0
        )
        #expect(key.horizontalSizeClass == 0)
        #expect(key.verticalSizeClass == 0)
    }

    @Test
    func keyEquality() {
        let bitmapKey = NamedImage.BitmapKey(
            catalogKey: CatalogKey(colorScheme: .light, contrast: .standard),
            name: "test",
            scale: 1.0,
            location: .system,
            layoutDirection: .leftToRight,
            locale: .autoupdatingCurrent,
            gamut: .sRGB,
            idiom: 0,
            subtype: 0
        )
        let key1 = NamedImage.Key.bitmap(bitmapKey)
        let key2 = NamedImage.Key.bitmap(bitmapKey)
        #expect(key1 == key2)
    }

    @Test
    func keyInequalityDifferentCases() {
        let bitmapKey = NamedImage.BitmapKey(
            catalogKey: CatalogKey(colorScheme: .light, contrast: .standard),
            name: "test",
            scale: 1.0,
            location: .system,
            layoutDirection: .leftToRight,
            locale: .autoupdatingCurrent,
            gamut: .sRGB,
            idiom: 0,
            subtype: 0
        )
        let key1 = NamedImage.Key.bitmap(bitmapKey)
        let key2 = NamedImage.Key.uuid(UUID())
        #expect(key1 != key2)
    }

    @Test
    func keyUUIDEquality() {
        let uuid = UUID()
        let key1 = NamedImage.Key.uuid(uuid)
        let key2 = NamedImage.Key.uuid(uuid)
        #expect(key1 == key2)
    }

    @Test
    func keyUUIDInequality() {
        let key1 = NamedImage.Key.uuid(UUID())
        let key2 = NamedImage.Key.uuid(UUID())
        #expect(key1 != key2)
    }
}

// MARK: - Image.Location Tests

struct ImageLocationTests {
    @Test
    func systemEquality() {
        #expect(Image.Location.system == Image.Location.system)
    }

    @Test
    func privateSystemEquality() {
        #expect(Image.Location.privateSystem == Image.Location.privateSystem)
    }

    @Test
    func bundleEquality() {
        let bundle = Bundle.main
        #expect(Image.Location.bundle(bundle) == Image.Location.bundle(bundle))
    }

    @Test
    func differentCasesNotEqual() {
        #expect(Image.Location.system != Image.Location.privateSystem)
        #expect(Image.Location.system != Image.Location.bundle(.main))
        #expect(Image.Location.privateSystem != Image.Location.bundle(.main))
    }

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
    func hashConsistency() {
        let loc1 = Image.Location.system
        let loc2 = Image.Location.system
        #expect(loc1.hashValue == loc2.hashValue)
    }

    @Test
    func hashDifferentCases() {
        let systemHash = Image.Location.system.hashValue
        let privateHash = Image.Location.privateSystem.hashValue
        let bundleHash = Image.Location.bundle(.main).hashValue
        // All three should be different (technically not guaranteed, but highly likely)
        #expect(systemHash != privateHash)
        #expect(systemHash != bundleHash)
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
    func equality() {
        let provider1 = Image.NamedImageProvider(
            name: "star",
            location: .system,
            label: nil,
            decorative: false
        )
        let provider2 = Image.NamedImageProvider(
            name: "star",
            location: .system,
            label: nil,
            decorative: false
        )
        #expect(provider1 == provider2)
    }

    @Test
    func inequalityDifferentName() {
        let provider1 = Image.NamedImageProvider(
            name: "star",
            location: .system,
            label: nil,
            decorative: false
        )
        let provider2 = Image.NamedImageProvider(
            name: "heart",
            location: .system,
            label: nil,
            decorative: false
        )
        #expect(provider1 != provider2)
    }

    @Test
    func inequalityDifferentLocation() {
        let provider1 = Image.NamedImageProvider(
            name: "star",
            location: .system,
            label: nil,
            decorative: false
        )
        let provider2 = Image.NamedImageProvider(
            name: "star",
            location: .bundle(.main),
            label: nil,
            decorative: false
        )
        #expect(provider1 != provider2)
    }

    @Test
    func inequalityDifferentDecorative() {
        let provider1 = Image.NamedImageProvider(
            name: "star",
            location: .system,
            label: nil,
            decorative: false
        )
        let provider2 = Image.NamedImageProvider(
            name: "star",
            location: .system,
            label: nil,
            decorative: true
        )
        #expect(provider1 != provider2)
    }

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
}
