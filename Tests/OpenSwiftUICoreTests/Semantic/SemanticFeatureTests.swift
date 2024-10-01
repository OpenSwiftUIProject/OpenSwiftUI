//
//  SemanticFeatureTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

@MainActor
struct SemanticFeatureTests {
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
        #if canImport(Darwin)
        #expect(SemanticFeature1.isEnabled == true)
        #expect(SemanticFeature2.isEnabled == false)
        #expect(SemanticFeature3.isEnabled == false)
        #else
        #expect(SemanticFeature1.isEnabled == true)
        #expect(SemanticFeature2.isEnabled == true)
        #expect(SemanticFeature3.isEnabled == true)
        #endif
    }
    
    @Test
    func changeForceEnable() async throws {
        SemanticFeature2.introduced.test(as: \.sdk) {
            #expect(SemanticFeature1.isEnabled == true)
            #expect(SemanticFeature2.isEnabled == true)
            #expect(SemanticFeature3.isEnabled == false)
        }
        SemanticFeature3.introduced.test(as: \.sdk) {
            #expect(SemanticFeature1.isEnabled == true)
            #expect(SemanticFeature2.isEnabled == true)
            #expect(SemanticFeature3.isEnabled == true)
        }
    }
}
