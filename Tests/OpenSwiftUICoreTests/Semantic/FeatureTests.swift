//
//  FeatureTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing
import Foundation

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
    
    @Test
    func userDefaults() {
        struct Feature1: UserDefaultKeyedFeature {
            static var key: String { "org.OpenSwiftUIProject.OpenSwiftUICoreTests.Feature1" }
            static var cachedValue: Bool?
        }
        #expect(Feature1.isEnabled == false)
        Feature1.test(enabled: true) {
            #expect(Feature1.isEnabled == true)
        }
        #expect(Feature1.isEnabled == false)
        UserDefaults.standard.set(true, forKey: Feature1.key)
        #expect(Feature1.isEnabled == false)
        Feature1.cachedValue = nil
        #expect(Feature1.isEnabled == true)
        UserDefaults.standard.removeObject(forKey: Feature1.key)
    }
}
