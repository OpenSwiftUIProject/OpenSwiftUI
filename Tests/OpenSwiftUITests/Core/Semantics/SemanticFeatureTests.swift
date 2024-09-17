//
//  SemanticFeatureTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUI
import Testing

@MainActor
final class SemanticFeatureTests {
    private let originalValue: Semantics?
    
    init() {
        originalValue = Semantics.forced
    }
    
    deinit {
        Semantics.forced = originalValue
    }
    
    /// Represent a minimum version
    struct SemanticFeature1: SemanticFeature {
        static var introduced: Semantics { .init(value: 0x0000_0000) }
    }
    
    /// Represent a middle version
    struct SemanticFeature2: SemanticFeature {
        static var introduced: Semantics { .init(value: 0xFFFF_0000) }
    }
    
    /// Represent a maximum version
    struct SemanticFeature3: SemanticFeature {
        static var introduced: Semantics { .init(value: 0xFFFF_FFFF) }
    }
    
    @Test
    func defaultEnable() async throws {
        #expect(Semantics.forced == nil)
        #if canImport(Darwin)
        #expect(SemanticFeature1.isEnable == true)
        #expect(SemanticFeature2.isEnable == false)
        #expect(SemanticFeature3.isEnable == false)
        #else
        #expect(SemanticFeature1.isEnable == true)
        #expect(SemanticFeature2.isEnable == true)
        #expect(SemanticFeature3.isEnable == true)
        #endif
    }
    
    @Test
    func changeForceEnable() async throws {
        do {
            let oldValue = Semantics.forced
            Semantics.forced = SemanticFeature2.introduced
            defer { Semantics.forced = oldValue }
            #expect(SemanticFeature1.isEnable == true)
            #expect(SemanticFeature2.isEnable == true)
            #expect(SemanticFeature3.isEnable == false)
        }
        do {
            let oldValue = Semantics.forced
            Semantics.forced = SemanticFeature3.introduced
            defer { Semantics.forced = oldValue }
            #expect(SemanticFeature1.isEnable == true)
            #expect(SemanticFeature2.isEnable == true)
            #expect(SemanticFeature3.isEnable == true)
        }
    }
}
