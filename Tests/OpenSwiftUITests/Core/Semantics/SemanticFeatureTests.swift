//
//  SemanticFeatureTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUI
import Testing

struct SemanticFeatureTests {
    struct SemanticFeature1: SemanticFeature {
        static var introduced: Semantics { .init(value: 0x0000_0000) }
    }
    
    struct SemanticFeature2: SemanticFeature {
        static var introduced: Semantics { .init(value: 0xFFFF_0000) }
    }
    
    struct SemanticFeature3: SemanticFeature {
        static var introduced: Semantics { .init(value: 0xFFFF_FFFF) }
    }
    
    @Test
    func defaultEnable() async throws {
        #expect(Semantics.forced == nil)
        #expect(SemanticFeature1.isEnable == true)
        #expect(SemanticFeature2.isEnable == false)
        #expect(SemanticFeature3.isEnable == false)
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
