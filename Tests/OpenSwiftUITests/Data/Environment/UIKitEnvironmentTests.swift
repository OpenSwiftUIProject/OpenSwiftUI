//
//  UIKitEnvironmentTests.swift
//  OpenSwiftUITests

#if os(iOS) || os(visionOS)
@testable import OpenSwiftUI
import Testing
import UIKit

@MainActor
struct UIKitEnvironmentTests {
    @Test
    func overrideTrait() {
        let trait = UITraitCollection()
        #expect(trait.layoutDirection == .unspecified)
        var environment = EnvironmentValues()
        environment.layoutDirection = .rightToLeft
        let newTrait = trait.byOverriding(with: environment, viewPhase: .init(), focusedValues: .init())
        #expect(newTrait.layoutDirection == .rightToLeft)
    }
}
#endif
