//
//  AnimationTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

struct AnimationCompatibilityTests {
    @Test
    func description() {
        let animation = Animation.default
        #expect(animation.description == "DefaultAnimation()")
        #if OPENSWIFTUI_COMPATIBILITY_TEST
        #expect(animation.debugDescription == "AnyAnimator(SwiftUI.DefaultAnimation())")
        #else
        #expect(animation.debugDescription == "AnyAnimator(OpenSwiftUICore.DefaultAnimation())")
        #endif
        #expect(animation.customMirror.description == "Mirror for Animation")
    }
}
