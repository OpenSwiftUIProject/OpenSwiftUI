//
//  ContentTransitionBackendTests.swift
//  OpenSwiftUICoreTests

import OpenRenderBoxShims
@_spi(Private) @testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc))
struct ContentTransitionBackendTests {
    @Test(arguments: [
        (ContentTransition.default, ORBTransitionMethod.binary, 1),
        (.identity, .none, 0), (.opacity, .none, 1),
        (.interpolate, .diff, 1), (.fadeIfDifferent, .binary, 1),
        (.text, .diff, 1), (.differentText, .binary, 1),
    ])
    func namedTransitions(transition: ContentTransition, method: ORBTransitionMethod, count: Int) {
        let backend = transition.rbTransition
        #expect(backend.method == method)
        #expect(backend.effects.count == count)
        if count > 0 {
            #expect(backend.effects[0].type == .alpha)
            #expect(backend.effects[0].duration == 0)
        }
        #expect(backend === transition.rbTransition)
        var replaceable = transition
        replaceable.isReplaceable = true
        #expect(replaceable.rbTransition !== backend)
        #expect(replaceable.rbTransition.isReplaceable)
        #expect(!backend.isReplaceable)
    }

    @Test(arguments: [LayoutDirection.leftToRight, .rightToLeft])
    func customEffectsPreserveArgumentsAndResolveDirection(direction: LayoutDirection) {
        var transition = ContentTransition(method: .diff, effects: [
            .sequence(direction: .leading, delay: 0.15, maxAllowedDurationMultiple: 2),
            .init(type: .init(type: .replace, arg0: .int(0x3f800001), arg1: .float(0.75)), begin: 0.25, duration: 0.5, events: .remove, flags: .removeInverts),
        ])
        transition.applyEnvironmentValues(style: .default, layoutDirection: direction)
        transition.isReplaceable = true
        let backend = transition.rbTransition
        #expect(backend !== transition.rbTransition)
        #expect(backend.isReplaceable)
        #expect(backend.method == .diff)
        #expect(backend.effects[0].type == (direction == .leftToRight ? .sequenceLeft : .sequenceRight))
        #expect(backend.effects[0].beginTime == Float(38) * (1 / 255))
        #expect(backend.effects[0].duration == Float(128) * (1 / 255))
        let effect = backend.effects[1]
        #expect(effect.integerArgumentValue(at: 0) == 0x3f800001)
        #expect(effect.argumentValue(at: 1) == 0.75)
        #expect(effect.events == .remove)
        #expect(effect.flags == .removeInverts)
    }

    @Test
    func numericDescriptors() throws {
        let backend = ContentTransition.numericText(.fixed(downwards: false)).rbTransition
        #expect(backend.method == .prefixAndSuffix)
        #expect(backend.effects.map(\.type) == [.sequenceLeft, .alpha, .relativeBlur, .relativeTranslation, .scaleCenter])
        #expect(backend.effects[0].beginTime == Float(38) * (1 / 255))
        #expect(backend.effects[0].duration == Float(204) * (1 / 255))
        #expect(backend.effects[2].argumentValue(at: 0) == 0)
        #expect(backend.effects[2].argumentValue(at: 1) == 0.25)
        #expect(backend.effects[3].argumentValue(at: 0) == 0)
        #expect(backend.effects[3].argumentValue(at: 1) == 19.0 / 32)
        #expect(backend.effects[3].flags == .removeInverts)
        #expect(backend.effects[3].animationIndex == 1)
        #expect(backend.effects[4].argumentValue(at: 0) == 51.0 / 128)
        let expected = ORBAnimation()
        expected.addSpringDuration(0.5, mass: 1, stiffness: 344, damping: 37, initialVelocity: 0)
        expected.addSpringDuration(0.8, mass: 2, stiffness: 470, damping: 34, initialVelocity: 0)
        #expect(try #require(backend.animation).isEqual(expected))
    }

    @Test(arguments: [LayoutDirection.leftToRight, .rightToLeft])
    func numericAxisDirectionAndBlur(direction: LayoutDirection) {
        var config = ContentTransition.NumericTextConfiguration.fixed(downwards: true)
        config.axis = .horizontal
        config.options.insert(.reversed)
        config.blur = 4
        config.offset = -0.5
        var transition = ContentTransition.numericText(config)
        transition.applyEnvironmentValues(style: .default, layoutDirection: direction)
        let effects = transition.rbTransition.effects
        #expect(effects[0].type == (direction == .leftToRight ? .sequenceRight : .sequenceLeft))
        #expect(effects[2].type == .blur)
        #expect(effects[2].argumentValue(at: 0) == 4)
        #expect(effects[3].argumentValue(at: 0) == 0.5)
        #expect(effects[3].argumentValue(at: 1) == 0)
        config.axis = .vertical
        config.direction = .automatic(value: -12)
        let automatic = ContentTransition.numericText(config).rbTransition.effects
        #expect(automatic[0].type == .sequenceDown)
        #expect(automatic[3].flags.rawValue == 3)
        #expect(automatic[3].argumentValue(at: 0) == 0)
        #expect(automatic[3].argumentValue(at: 1) == -0.5)
    }

    @Test(arguments: [LayoutDirection.leftToRight, .rightToLeft])
    func widgetStyles(direction: LayoutDirection) throws {
        var transition = ContentTransition.differentText
        transition.applyEnvironmentValues(style: .sessionWidget, layoutDirection: direction)
        let session = transition.rbTransition
        #expect(session.method == .prefixAndSuffix)
        #expect(session.maxChanges == 10)
        #expect(session.effects.map { $0.type.rawValue } == [direction == .leftToRight ? 11 : 12, 1, 1, direction == .leftToRight ? 7 : 8, 16, 6, 2])
        #expect(session.effects.map { $0.events.rawValue } == [7, 7, 11, 7, 3, 7, 11])
        #expect(session.effects[0].flags == .removeInverts)
        #expect(session.effects[4].argumentValue(at: 1) == 0.25)
        #expect(session.effects[5].argumentValue(at: 0) == 0.5)
        #expect(session.effects[6].argumentValue(at: 0) == 0.85)
        transition.style = .animatedWidget
        let animated = transition.rbTransition
        #expect(animated.method == .binary)
        #expect(animated.effects.map(\.type) == [.alpha, .scaleCenter, .relativeBlur])
        #expect(animated.effects.allSatisfy { $0.insertAnimationIndex == 1 && $0.removeAnimationIndex == 0 })
        let expected = ORBAnimation()
        expected.addSpringDuration(0.5, mass: 1, stiffness: 331, damping: 36.4, initialVelocity: 0)
        expected.addSpringDuration(0.8, mass: 2, stiffness: 300, damping: 50, initialVelocity: 0)
        #expect(try #require(animated.animation).isEqual(expected))
    }

    @Test(arguments: [true, false])
    func symbolReplacement(layered: Bool) {
        var config = _SymbolEffect.ReplaceConfiguration()
        config.layered = layered
        config.speed = 3
        var transition = ContentTransition(storage: .symbolReplace(config))
        transition.isReplaceable = true
        let backend = transition.rbTransition
        #expect(backend.method == .binary)
        #expect(!backend.isReplaceable)
        #expect(backend.effects[0].type == .replace)
        #expect(backend.effects[0].integerArgumentValue(at: 0) == (layered ? 0 : 16))
        #expect(backend.effects[0].argumentValue(at: 1) == 1)
    }
}
