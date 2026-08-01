//
//  AnimationTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

struct AnimationCompatibilityTests {
    @Test
    func description() {
        let animation = Animation.default
        #expect(animation.description == "DefaultAnimation()")
        #expect(animation.debugDescription == "AnyAnimator(OpenSwiftUI.DefaultAnimation())".normalizeSwiftUI)
        #expect(animation.customMirror.description == "Mirror for Animation")
    }
}
