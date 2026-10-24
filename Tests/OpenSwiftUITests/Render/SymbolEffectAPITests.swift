//
//  SymbolEffectAPITests.swift
//  OpenSwiftUITests

#if OPENSWIFTUI_LINK_SYMBOLS
import OpenAttributeGraphShims
@_spi(Private) @testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly) @_spi(Private) @testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
@_spi(Private) import Symbols
import Testing

@MainActor
struct SymbolEffectAPITests {
    @Suite(.disabled(if: attributeGraphVendor == .oag))
    @MainActor
    struct Modifiers {
        @Test
        func indefiniteActivationPreservesInheritedEffects() throws {
            var environment = EnvironmentValues()
            environment.appendSymbolEffect(_SymbolEffect(.none), for: 7)
            let modifier = _IndefiniteSymbolEffectModifier(
                effect: PulseSymbolEffect.pulse.wholeSymbol,
                options: .speed(2),
                isActive: false
            )
            try SymbolEffectAPITests.withEnvironment(modifier, environment: environment) { attribute, output in
                #expect(output.value.symbolEffects == environment.symbolEffects)
                var active = modifier
                active.isActive = true
                attribute.value = active
                let effects = output.value.symbolEffects
                #expect(effects.count == 2)
                #expect(effects.first == environment.symbolEffects.first)
                let effect = try #require(effects.last)
                guard case let .pulse(pulse) = effect.effect.storage else {
                    Issue.record("Expected a pulse effect")
                    return
                }
                #expect(pulse.layered == false)
                #expect(pulse.trigger == nil)
                #expect(effect.effect.options.speed == 2)
                active.options = .speed(3)
                attribute.value = active
                #expect(output.value.symbolEffects.last?.identifier == effect.identifier)
                #expect(output.value.symbolEffects.last?.effect.options.speed == 3)
            }
        }

        @Test(arguments: [
            BounceSymbolEffect.bounce.configuration,
            WiggleSymbolEffect.wiggle.configuration,
            RotateSymbolEffect.rotate.configuration,
        ])
        func continuousDefaultsDependOnTrigger(configuration: SymbolEffectConfiguration) throws {
            let effect = Effect(configuration: configuration)
            let cases: [(SymbolEffectOptions.RepeatOption?, Bool, Bool, Bool)] = [
                (nil, false, true, false),
                (nil, true, true, false),
                (.count(3), false, false, false),
                (.count(3), true, true, true),
                (.indefinite, false, false, false),
                (.indefinite, true, true, true),
            ]
            for (repetition, prefersContinuous, expectedIndefinite, expectedDiscrete) in cases {
                var options = SymbolEffectOptions.default
                options.repeat = repetition
                options.prefersContinuous = prefersContinuous
                let indefinite = _IndefiniteSymbolEffectModifier(effect: effect, options: options, isActive: true)
                let discrete = _DiscreteSymbolEffectModifier(effect: effect, options: options, value: 42)
                try SymbolEffectAPITests.withEnvironment(indefinite) { _, output in
                    let value = try #require(output.value.symbolEffects.first?.effect)
                    #expect(continuous(value) == expectedIndefinite)
                }
                try SymbolEffectAPITests.withEnvironment(discrete) { _, output in
                    let value = try #require(output.value.symbolEffects.first?.effect)
                    #expect(continuous(value) == expectedDiscrete)
                }
            }
        }

        @Test
        func scalePreservesOptionalDirectionAndLayering() throws {
            let cases: [(ScaleSymbolEffect, Int32, Bool)] = [
                (.scale, 0, true),
                (.scale.up.wholeSymbol, 1, false),
                (.scale.down.byLayer, -1, true),
            ]
            for (effect, level, layered) in cases {
                let modifier = _IndefiniteSymbolEffectModifier(effect: effect, options: .default, isActive: true)
                try SymbolEffectAPITests.withEnvironment(modifier) { _, output in
                    guard case let .scale(value) = try #require(output.value.symbolEffects.first?.effect.storage) else {
                        Issue.record("Expected a scale effect")
                        return
                    }
                    #expect(value.level.rawValue == level)
                    #expect(value.layered == layered)
                }
            }
        }

        @Test
        func indefiniteAppearAndDisappearUseHiddenState() throws {
            let cases: [(SymbolEffectConfiguration, UInt32, Bool)] = [
                (AppearSymbolEffect.appear.configuration, 0, true),
                (AppearSymbolEffect.appear.up.configuration, 2, true),
                (AppearSymbolEffect.appear.down.wholeSymbol.configuration, 3, false),
                (DisappearSymbolEffect.disappear.configuration, 0, true),
                (DisappearSymbolEffect.disappear.up.configuration, 3, true),
                (DisappearSymbolEffect.disappear.down.wholeSymbol.configuration, 2, false),
            ]
            for (configuration, flags, layered) in cases {
                let modifier = _IndefiniteSymbolEffectModifier(
                    effect: Effect(configuration: configuration), options: .default, isActive: true
                )
                try SymbolEffectAPITests.withEnvironment(modifier) { _, output in
                    guard case let .hidden(value) = try #require(output.value.symbolEffects.first?.effect.storage) else {
                        Issue.record("Expected a hidden effect")
                        return
                    }
                    #expect(value.flags.rawValue == flags)
                    #expect(value.layered == layered)
                    #expect(value.isHidden)
                }
            }
        }

        @Test(arguments: [
            PulseSymbolEffect.pulse.configuration,
            BounceSymbolEffect.bounce.configuration,
            VariableColorSymbolEffect.variableColor.configuration,
            WiggleSymbolEffect.wiggle.configuration,
            RotateSymbolEffect.rotate.configuration,
            BreatheSymbolEffect.breathe.configuration,
        ])
        func triggersReachStorage(configuration: SymbolEffectConfiguration) throws {
            let effect = Effect(configuration: configuration)
            let discrete = _DiscreteSymbolEffectModifier(effect: effect, options: .default, value: 42)
            try SymbolEffectAPITests.withEnvironment(discrete) { attribute, output in
                let initial = try #require(output.value.symbolEffects.first?.effect)
                #expect(trigger(initial) == .value(AnyEquatable(42)))
                var changed = discrete
                changed.value = 43
                attribute.value = changed
                let updated = try #require(output.value.symbolEffects.first?.effect)
                #expect(trigger(updated) == .value(AnyEquatable(43)))
            }
            let conditional = _ConditionalSymbolEffectModifier(effect: effect, options: .default, condition: false)
            try SymbolEffectAPITests.withEnvironment(conditional) { attribute, output in
                let initial = try #require(output.value.symbolEffects.first?.effect)
                #expect(trigger(initial) == .condition(false))
                var changed = conditional
                changed.condition = true
                attribute.value = changed
                let updated = try #require(output.value.symbolEffects.first?.effect)
                #expect(trigger(updated) == .condition(true))
            }
        }

        @Test(arguments: [
            ScaleSymbolEffect.scale.configuration,
            AppearSymbolEffect.appear.configuration,
            DisappearSymbolEffect.disappear.configuration,
            ReplaceSymbolEffect.replace.configuration,
            AutomaticSymbolEffect.automatic.configuration,
            ReplaceSymbolEffect.replace.magic(fallback: .replace).configuration,
        ])
        func discreteRejectsUnsupportedEffects(configuration: SymbolEffectConfiguration) {
            let modifier = _DiscreteSymbolEffectModifier(
                effect: Effect(configuration: configuration), options: .default, value: 1
            )
            SymbolEffectAPITests.withEnvironment(modifier) { _, output in
                #expect(output.value.symbolEffects.isEmpty)
            }
        }

        @Test(arguments: [
            ReplaceSymbolEffect.replace.configuration,
            AutomaticSymbolEffect.automatic.configuration,
            ReplaceSymbolEffect.replace.magic(fallback: .replace).configuration,
        ])
        func indefiniteRejectsUnsupportedEffects(configuration: SymbolEffectConfiguration) {
            let modifier = _IndefiniteSymbolEffectModifier(
                effect: Effect(configuration: configuration), options: .default, isActive: true
            )
            SymbolEffectAPITests.withEnvironment(modifier) { _, output in
                #expect(output.value.symbolEffects.isEmpty)
            }
        }

        @Test
        func optionsPreserveRepeatAndFloatConversions() throws {
            let cases: [(SymbolEffectOptions.RepeatOption?, Double?, Double, Float?, Float?, Float)] = [
                (nil, nil, 1, nil, nil, 1),
                (.count(0), 0, 0, 0, 0, 0),
                (.count(-2), -0.25, -2, -2, -0.25, -2),
                (.count(16_777_217), 0.25, 2.5, 16_777_216, 0.25, 2.5),
                (.indefinite, .infinity, .infinity, .infinity, .infinity, .infinity),
            ]
            for (repetition, delay, speed, expectedCount, expectedDelay, expectedSpeed) in cases {
                var options = SymbolEffectOptions.default
                options.repeat = repetition
                options.repeatDelay = delay
                options.speed = speed
                let modifier = _DiscreteSymbolEffectModifier(effect: PulseSymbolEffect.pulse, options: options, value: 0)
                try SymbolEffectAPITests.withEnvironment(modifier) { _, output in
                    let result = try #require(output.value.symbolEffects.first?.effect.options)
                    #expect(result.repeatCount == expectedCount)
                    #expect(result.repeatDelay == expectedDelay)
                    #expect(result.speed == expectedSpeed)
                }
            }
        }

        @Test
        func stylesMapToRenderOptions() throws {
            let cases: [(SymbolEffectConfiguration, UInt32, Bool)] = [
                (.init(effect: .bounce(.bounce.up.wholeSymbol)), 1, false),
                (.init(effect: .bounce(.bounce.down.byLayer)), 2, true),
                (.init(effect: .rotate(.rotate.clockwise.wholeSymbol)), 1, false),
                (.init(effect: .rotate(.rotate.counterClockwise.byLayer)), 2, true),
                (.init(effect: .breathe(.breathe.plain)), 1, true),
                (.init(effect: .breathe(.breathe.pulse.wholeSymbol)), 0, false),
            ]
            for (configuration, flags, layered) in cases {
                let modifier = _DiscreteSymbolEffectModifier(effect: Effect(configuration: configuration), options: .default, value: 0)
                try SymbolEffectAPITests.withEnvironment(modifier) { _, output in
                    switch try #require(output.value.symbolEffects.first?.effect.storage) {
                    case let .bounce(value):
                        #expect(value.flags.rawValue == flags)
                        #expect(value.layered == layered)
                    case let .rotate(value):
                        #expect(value.flags.rawValue == flags)
                        #expect(value.layered == layered)
                    case let .breathe(value):
                        #expect(value.flags.rawValue == flags)
                        #expect(value.layered == layered)
                    default:
                        Issue.record("Unexpected effect kind")
                    }
                }
            }
        }

        @Test
        func variableColorMapsIndependentFlags() throws {
            let modifier = _DiscreteSymbolEffectModifier(
                effect: VariableColorSymbolEffect.variableColor.iterative.reversing.hideInactiveLayers,
                options: .default, value: 0
            )
            try SymbolEffectAPITests.withEnvironment(modifier) { _, output in
                guard case let .variableColor(value) = try #require(output.value.symbolEffects.first?.effect.storage) else {
                    Issue.record("Expected a variable color effect")
                    return
                }
                #expect(value.flags.rawValue == 0xB)
            }
        }

        @Test
        func wiggleConvertsAnglesAndLocalizedDirections() throws {
            let cases: [(Symbols.WiggleSymbolEffect.WiggleStyle?, UInt32, Double?, Bool)] = [
                (nil, 0, nil, false),
                (.rotational(true), 0x13, nil, false),
                (.rotational(false), 0x23, nil, false),
                (.linear(90), 0, .pi / 2, false),
                (.localized(true), 0x21, nil, true),
                (.localized(false), 0x11, nil, true),
            ]
            for (style, flags, radians, rtl) in cases {
                var effect = WiggleSymbolEffect.wiggle.wholeSymbol
                effect.style = style
                var environment = EnvironmentValues()
                environment.layoutDirection = .rightToLeft
                let modifier = _DiscreteSymbolEffectModifier(effect: effect, options: .default, value: 0)
                try SymbolEffectAPITests.withEnvironment(modifier, environment: environment) { _, output in
                    guard case let .wiggle(value) = try #require(output.value.symbolEffects.first?.effect.storage) else {
                        Issue.record("Expected a wiggle effect")
                        return
                    }
                    #expect(value.flags.rawValue == flags)
                    #expect(value.angle?.radians == radians)
                    #expect(value.layered == false)
                    #expect(value.appliesRTL == false)
                    if rtl { #expect(value.flags.contains(.localized)) }
                }
            }
        }

        private func continuous(_ effect: _SymbolEffect) -> Bool? {
            switch effect.storage {
            case let .bounce(value): value.flags.contains(.continuous)
            case let .wiggle(value): value.flags.contains(.continuous)
            case let .rotate(value): value.flags.contains(.continuous)
            default: nil
            }
        }

        private func trigger(_ effect: _SymbolEffect) -> _SymbolEffect.Trigger? {
            switch effect.storage {
            case let .pulse(value): value.trigger
            case let .bounce(value): value.trigger
            case let .variableColor(value): value.trigger
            case let .wiggle(value): value.trigger
            case let .rotate(value): value.trigger
            case let .breathe(value): value.trigger
            default: nil
            }
        }
    }

    @Test
    func hiddenTransitionMapsDirectionAndLayering() throws {
        let cases: [(SymbolEffectConfiguration, UInt32)] = [
            (AppearSymbolEffect.appear.configuration, 0),
            (AppearSymbolEffect.appear.up.configuration, 2),
            (AppearSymbolEffect.appear.down.wholeSymbol.configuration, 0x13),
            (DisappearSymbolEffect.disappear.up.configuration, 3),
            (DisappearSymbolEffect.disappear.down.wholeSymbol.configuration, 0x12),
            (AutomaticSymbolEffect.automatic.configuration, 0),
        ]
        for (configuration, flags) in cases {
            let value = SymbolEffectTransition(effect: Effect(configuration: configuration), options: .speed(2.5))
            var transition = _Transition_ContentTransition(operation: .effects(style: .default, size: .zero), result: .none)
            value._makeContentTransition(transition: &transition)
            guard case let .effects(effects) = transition.result else {
                Issue.record("Expected symbol transition effects")
                continue
            }
            let effect = try #require(effects.first)
            #expect(effects.count == 1)
            #expect(effect.type.type == .symbolAppearDisappear)
            #expect(effect.type.arg0 == .int(flags))
            #expect(effect.type.arg1 == .float(2.5))
            transition = .init(operation: .hasContentTransition, result: .none)
            value._makeContentTransition(transition: &transition)
            guard case let .bool(result) = transition.result else {
                Issue.record("Expected a content transition")
                continue
            }
            #expect(result)
        }
    }

    @Test(arguments: [Semantics.v5, .v6])
    func replacementStylesAndMagic(semantics: Semantics) throws {
        try semantics.test {
            let cases: [(SymbolEffectConfiguration, UInt32, Bool)] = [
                (AutomaticSymbolEffect.automatic.configuration, 0, true),
                (ReplaceSymbolEffect.replace.configuration, semantics == .v6 ? 0 : 0x60, true),
                (ReplaceSymbolEffect.replace.downUp.configuration, 0x62, true),
                (ReplaceSymbolEffect.replace.upUp.wholeSymbol.configuration, 0x63, false),
                (ReplaceSymbolEffect.replace.offUp.configuration, 0x64, true),
                (ReplaceSymbolEffect.replace.magic(fallback: .replace.offUp.wholeSymbol).configuration, 4, false),
            ]
            for (configuration, flags, layered) in cases {
                let transition = ContentTransition.symbolEffect(Effect(configuration: configuration), options: .speed(2.5))
                guard case let .symbolReplace(value) = transition.storage else {
                    Issue.record("Expected a symbol replacement transition")
                    continue
                }
                #expect(value.flags.rawValue == flags)
                #expect(value.layered == layered)
                #expect(value.speed == 2.5)
            }
        }
    }

    @Test
    func unsupportedTransitionsPreserveFallbacks() {
        let effect = Effect(configuration: PulseSymbolEffect.pulse.configuration)
        #expect(ContentTransition.symbolEffect(effect) == .default)
        let value = SymbolEffectTransition(effect: effect, options: .default)
        var transition = _Transition_ContentTransition(operation: .effects(style: .default, size: .zero), result: .none)
        value._makeContentTransition(transition: &transition)
        guard case .none = transition.result else {
            Issue.record("Expected the unsupported transition to retain its result")
            return
        }
        transition = .init(operation: .hasContentTransition, result: .bool(false))
        value._makeContentTransition(transition: &transition)
        guard case let .bool(result) = transition.result else {
            Issue.record("Expected the unsupported transition to retain its result")
            return
        }
        #expect(result == false)
    }

    private struct Effect: Symbols.SymbolEffect, IndefiniteSymbolEffect, DiscreteSymbolEffect,
        TransitionSymbolEffect, ContentTransitionSymbolEffect {
        var configuration: SymbolEffectConfiguration
    }

    private static func withEnvironment<Modifier: _GraphInputsModifier>(
        _ modifier: Modifier,
        environment: EnvironmentValues = .init(),
        _ body: (Attribute<Modifier>, Attribute<EnvironmentValues>) throws -> Void
    ) rethrows {
        let graph = Graph(shared: Graph())
        let subgraph = Subgraph(graph: graph)
        defer { subgraph.invalidate() }
        let current = Subgraph.current
        Subgraph.current = subgraph
        defer { Subgraph.current = current }
        let attribute = Attribute(value: modifier)
        var inputs = _GraphInputs(
            time: Attribute(value: .zero),
            phase: Attribute(value: .init()),
            environment: Attribute(value: environment),
            transaction: Attribute(value: .init())
        )
        Modifier._makeInputs(modifier: _GraphValue(attribute), inputs: &inputs)
        try body(attribute, inputs.environment)
    }
}
#endif
