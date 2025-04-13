//
//  CUIDesignLibraryCacheKeyTests.swift
//  OpenSwiftUICoreTests

#if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI

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
