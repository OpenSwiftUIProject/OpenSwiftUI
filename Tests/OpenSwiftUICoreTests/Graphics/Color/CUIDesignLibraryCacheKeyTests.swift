//
//  CUIDesignLibraryCacheKeyTests.swift
//  OpenSwiftUICoreTests

#if canImport(Darwin)

@testable import OpenSwiftUICore
import Testing

@MainActor
struct CUIDesignLibraryCacheKeyTests {
    @Test
    func blendMode() {
        let key = CUIDesignLibraryCacheKey(name: .primary, in: .init(), allowsBlendMode: true)
        let entry = key.fetch()
        #expect(entry.blendMode == .normal)
    }
}
#endif
