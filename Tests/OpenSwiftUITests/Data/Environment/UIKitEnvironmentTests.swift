//
//  UIKitEnvironmentTests.swift
//  OpenSwiftUITests

#if os(iOS)
@testable import OpenSwiftUI
import Testing
import UIKit

struct UIKitEnvironmentTests {
    @Test
    func overrideTrait() {
        let trait = UITraitCollection.current
        #expect(trait.layoutDirection == .unspecified)
        var environment = EnvironmentValues()
        environment.layoutDirection = .rightToLeft
        let newTrait = trait.byOverriding(with: environment, viewPhase: .init(), focusedValues: .init())
        #expect(newTrait.layoutDirection == .rightToLeft)
    }
}
#endif
