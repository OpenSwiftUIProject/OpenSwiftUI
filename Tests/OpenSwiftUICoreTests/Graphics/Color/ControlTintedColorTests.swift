//
//  ControlTintedColorTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

struct ControlTintedColorTests {
    @Test
    func effectiveTintAdjustmentModeUsesExplicitValueThenEnabledFallback() {
        var environment = EnvironmentValues()

        #expect(environment.tintAdjustmentMode == nil)
        #expect(environment.effectiveTintAdjustmentMode == .normal)

        environment.isEnabled = false
        #expect(environment.effectiveTintAdjustmentMode == .desaturated)

        environment.tintAdjustmentMode = .normal
        #expect(environment.effectiveTintAdjustmentMode == .normal)

        environment.tintAdjustmentMode = .desaturated
        environment.isEnabled = true
        #expect(environment.effectiveTintAdjustmentMode == .desaturated)
    }

    @Test
    func tintAdjustmentModeDesaturatesResolvedColor() {
        let base = Color(Color.Resolved(
            linearRed: 0.25,
            linearGreen: 0.5,
            linearBlue: 0.75,
            opacity: 0.6
        ))
        let resolved = base.tintAdjustmentMode(.desaturated).resolve(in: .init())
        let expectedLuminance = base.resolve(in: .init()).linearWhite

        #expect(resolved.linearRed.isApproximatelyEqual(to: expectedLuminance))
        #expect(resolved.linearGreen.isApproximatelyEqual(to: expectedLuminance))
        #expect(resolved.linearBlue.isApproximatelyEqual(to: expectedLuminance))
        #expect(resolved.opacity.isApproximatelyEqual(to: 0.48))
    }

    @Test
    func tintAdjustedUsesEffectiveEnvironmentMode() {
        let base = Color(Color.Resolved(
            linearRed: 1.0,
            linearGreen: 0.0,
            linearBlue: 0.0,
            opacity: 0.5
        ))

        #expect(base.tintAdjusted.resolve(in: .init()) == base.resolve(in: .init()))

        var disabledEnvironment = EnvironmentValues()
        disabledEnvironment.isEnabled = false
        let resolved = base.tintAdjusted.resolve(in: disabledEnvironment)

        #expect(resolved.linearRed.isApproximatelyEqual(to: 0.2126))
        #expect(resolved.linearGreen.isApproximatelyEqual(to: 0.2126))
        #expect(resolved.linearBlue.isApproximatelyEqual(to: 0.2126))
        #expect(resolved.opacity.isApproximatelyEqual(to: 0.4))
    }
}
