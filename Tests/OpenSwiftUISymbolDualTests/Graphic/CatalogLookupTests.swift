//
//  CatalogLookupTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.0.87)
import Testing
import OpenSwiftUI

extension CatalogAssetMatchType {
    @_silgen_name("OpenSwiftUITestStub_CatalogAssetMatchType_DefaultValue")
    static func defaultValue(swiftUI_idiom: Int) -> [CatalogAssetMatchType]
}

struct CatalogAssetMatchTypeTests {
    @Test(arguments: [8])
    func defaultValue(idiom: Int) {
        let openSwiftUIValue = CatalogAssetMatchType.defaultValue(idiom: idiom)
        let swiftUIValue = CatalogAssetMatchType.defaultValue(swiftUI_idiom: idiom)
        print("Open: \(openSwiftUIValue) SwiftUI: \(swiftUIValue)")
        #expect(openSwiftUIValue == swiftUIValue)
    }
}

#endif
