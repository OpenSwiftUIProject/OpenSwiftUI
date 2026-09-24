//
//  IdentityLinkTests.swift
//  OpenSwiftUITests

import OpenAttributeGraphShims
#if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
@_private(sourceFile: "IdentityLink.swift")
#endif
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import Testing

@MainActor
@Suite
struct IdentityLinkTests {
    @Test
    func seed() {
        let identities = (0..<64).map { _ in ViewIdentity() }
        #expect(Set(identities).count == 64)
        #expect(!identities.contains(.invalid))
    }

    #if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
    @Test
    func overflow() {
        ViewIdentity.nextSeed = UInt32.max
        let id1 = ViewIdentity()
        #expect(id1.seed == UInt32.max)
        let id2 = ViewIdentity()
        #expect(id2 != .invalid)
        #expect(id2.seed == 1)
    }
    #endif

    #if !os(iOS) && !os(visionOS)
    @Test
    func readingBeforeInstallationFails() async throws {
        let result = try await #require(
            processExitsWith: .failure,
            observing: [\.standardErrorContent]
        ) {
            _ = IdentityLink().wrappedValue
        }
        #if DEBUG
        let diagnostic = String(decoding: result.standardErrorContent, as: UTF8.self)
        #expect(diagnostic.contains("Reading IdentityLink outside View.body"))
        #else
        _ = result
        #endif
    }
    #endif
}
