//
//  FeatureTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenSwiftUICore
import Testing

@MainActor
struct FeatureTests {
    @Test
    func defaultValue() {
        struct Feature1: Feature {
            static var isEnabled: Bool { false }
        }
        
        struct Feature2: Feature {
            static var isEnabled: Bool { true }
        }
        
        #expect(Feature1.defaultValue == false)
        #expect(Feature2.defaultValue == true)
    }
    
    #if !os(WASI)
    @Test
    func userDefaults() {
        struct Feature1: UserDefaultKeyedFeature {
            static let key = "Feature1"
            static let defaults = UserDefaults(
                suiteName: "org.OpenSwiftUIProject.OpenSwiftUICoreTests"
            )!
            static var cachedValue: Bool?
        }
        Feature1.defaults.removeObject(forKey: Feature1.key)
        Feature1.cachedValue = nil
        defer {
            Feature1.defaults.removeObject(forKey: Feature1.key)
            Feature1.cachedValue = nil
        }
        #expect(Feature1.isEnabled == false)
        Feature1.test(enabled: true) {
            #expect(Feature1.isEnabled == true)
        }
        #expect(Feature1.isEnabled == false)
        Feature1.defaults.set(true, forKey: Feature1.key)
        #expect(Feature1.isEnabled == false)
        Feature1.cachedValue = nil
        #expect(Feature1.isEnabled == true)
    }
    #endif
}
