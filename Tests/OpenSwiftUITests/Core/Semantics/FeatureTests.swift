//
//  FeatureTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUI
import Testing

struct FeatureTests {
    @Test
    func defaultValue() {
        struct Feature1: Feature {
            static var isEnable: Bool { false }
        }
        
        struct Feature2: Feature {
            static var isEnable: Bool { true }
        }
        
        #expect(Feature1.defaultValue == false)
        #expect(Feature2.defaultValue == true)
    }
}
