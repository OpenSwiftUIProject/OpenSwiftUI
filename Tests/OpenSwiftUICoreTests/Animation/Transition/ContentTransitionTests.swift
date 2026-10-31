//
//  ContentTransitionTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenAttributeGraphShims
@_spi(Private) @_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@MainActor
@Suite(.tags(.aigc))
struct ContentTransitionTests {
    @Test
    func publicModifierWritesTransitionEnvironment() throws {
        let view = EmptyView().contentTransition(.opacity)
        let modified = try #require(view as? ModifiedContent<EmptyView, _EnvironmentKeyWritingModifier<ContentTransition>>)
        #expect(modified.modifier.keyPath == \EnvironmentValues.contentTransition)
        #expect(modified.modifier.value == .opacity)
    }

    @Test(arguments: [
        (ContentTransition.default, ContentTransition.identity),
        (ContentTransition.default, ContentTransition.opacity),
        (ContentTransition.default, ContentTransition.interpolate),
        (ContentTransition.identity, ContentTransition.opacity),
        (ContentTransition.identity, ContentTransition.interpolate),
        (ContentTransition.opacity, ContentTransition.interpolate),
    ])
    func namedTransitionsAreDistinct(first: ContentTransition, second: ContentTransition) {
        #expect(first != second)
    }

    @Test
    func replacementFlagParticipatesInEquality() {
        var transition = ContentTransition.opacity
        transition.isReplaceable = true
        #expect(transition != .opacity)
        #expect(transition.isNamed(.opacity))
    }

    @Test
    func environmentOnlyFillsUnsetValues() {
        var transition = ContentTransition.opacity
        transition.style = .sessionWidget
        transition.isReplaceable = true
        transition.applyEnvironmentValues(style: .animatedWidget, layoutDirection: .rightToLeft)
        transition.applyEnvironmentValues(style: .default, layoutDirection: .leftToRight)
        guard case let .named(named) = transition.storage else {
            Issue.record("Expected a named transition")
            return
        }
        #expect(named.style == .sessionWidget)
        #expect(named.layoutDirection == .rightToLeft)
        #expect(transition.isReplaceable)
        transition.style = nil
        transition.applyEnvironmentValues(style: .animatedWidget, layoutDirection: .leftToRight)
        #expect(transition.style == .animatedWidget)
    }

    @Test
    func customTransitionPreservesEffectsAndDirection() {
        let effects: [ContentTransition.Effect] = [.init(.opacity), .init(.scale(0.5))]
        var transition = ContentTransition(method: .prefixAndSuffix, effects: effects)
        transition.style = .sessionWidget
        transition.applyEnvironmentValues(style: .animatedWidget, layoutDirection: .rightToLeft)
        transition.applyEnvironmentValues(style: .default, layoutDirection: .leftToRight)
        guard case let .custom(custom) = transition.storage else {
            Issue.record("Expected a custom transition")
            return
        }
        #expect(custom.method == .prefixAndSuffix)
        #expect(custom.effects == effects)
        #expect(custom.layoutDirection == .rightToLeft)
        #expect(transition.style == nil)
        #expect(transition.numericValue == nil)
        #expect(!transition.isNamed(.default))
    }

    @Test(arguments: [
        (Semantics.v5, false, true),
        (.v5, true, false),
        (.v6, false, false),
        (.v6, true, true),
    ])
    func fixedNumericDirection(semantics: Semantics, countsDown: Bool, expectedDownwards: Bool) {
        semantics.test(as: \.deploymentTarget) {
            let transition = ContentTransition.numericText(countsDown: countsDown)
            #expect(transition.isNamed(.numericText(.fixed(downwards: expectedDownwards))))
            #expect(transition.numericValue == nil)
        }
    }

    @Test(arguments: [0, -42.5, 16_777_217, Double.greatestFiniteMagnitude, .infinity, -.infinity])
    func automaticNumericValue(value: Double) {
        #expect(ContentTransition.numericText(value: value).numericValue == Float(value))
    }

    @Test
    func numericDefaultsAndFluentConfiguration() {
        let initial = ContentTransition.NumericTextConfiguration.fixed()
        #expect(initial.delay == Float(0.15))
        #expect(initial.scale == 51.0 / 128)
        #expect(initial.relativeBlur == 0.25)
        #expect(initial.offset == 19.0 / 32)
        #expect(initial.maxDurationMultiple == 1.25)
        let changed = initial.axis(.horizontal).delay(0.5).scale(0.75)
            .blur(radius: 2).relativeOffset(-0.5).reversed(true)
        #expect(changed.axis == .horizontal)
        #expect(changed.delay == 0.5)
        #expect(changed.scale == 0.75)
        #expect(changed.blur == 2)
        #expect(changed.offset == -0.5)
        #expect(changed.options == .reversed)
        #expect(changed.reversed(false).options.isEmpty)
        #expect(initial.axis == nil)
        #expect(initial.options == .relativeBlur)
    }

    static let offsetCases: [(Float, Float)] = [
        (-.infinity, -4),
        (-0.99, -31.0 / 32),
        (0, 0),
        (0.99, 31.0 / 32),
        (.infinity, 127.0 / 32),
        (.nan, -4),
    ]

    @Test(arguments: offsetCases)
    func numericOffsetClampsAndTruncates(input: Float, expected: Float) {
        var config = ContentTransition.NumericTextConfiguration.fixed()
        config.offset = input
        #expect(config.offset == expected)
    }

    static let unsignedInputs: [Float] = [-.infinity, -1, 0, 0.123, 1, 10, .infinity, .nan]

    @Test(arguments: unsignedInputs)
    func numericUnsignedFieldsClampAndTruncate(input: Float) {
        var config = ContentTransition.NumericTextConfiguration.fixed().reversed(true)
        config.delay = input
        config.scale = input
        config.blur = input
        let bounded = input.isNaN ? 0 : max(0, input)
        #expect(abs(config.delay - floor(min(255, bounded * 120)) / 120) < 0.000001)
        #expect(config.scale == floor(min(255, bounded * 128)) / 128)
        #expect(config.blur == floor(min(255, bounded * 4)) / 4)
        #expect(config.options == .reversed)
        config.relativeBlur = input
        #expect(config.relativeBlur == floor(min(255, bounded * 128)) / 128)
        #expect(config.options == [.relativeBlur, .reversed])
    }

    @Test(arguments: [
        (ContentTransition.SequenceDirection.leading, UInt32(11)),
        (.trailing, 12), (.up, 13), (.down, 14), (.forwards, 19), (.backwards, 20),
    ])
    func sequenceConfiguration(direction: ContentTransition.SequenceDirection, rawType: UInt32) {
        let effect = ContentTransition.Effect.sequence(
            direction: direction, delay: 0.25, maxAllowedDurationMultiple: 2,
            appliesOnInsertion: false, appliesOnRemoval: false
        )
        #expect(effect.type.type.rawValue == rawType)
        #expect(effect.begin == 0.25)
        #expect(effect.duration == 0.5)
        // The sequence factory applies to both events in the target version.
        #expect(effect.events == .addRemove)
        #expect(ContentTransition.Effect.sequence(direction: direction, delay: 0).duration == 0)
    }

    @Test(arguments: [false, true], [false, true])
    func effectEventsAndRemovalInversion(insertion: Bool, removal: Bool) {
        let effect = ContentTransition.Effect(
            .opacity, timeline: 0.25 ... 0.75,
            appliesOnInsertion: insertion, appliesOnRemoval: removal
        )
        #expect(effect.begin == 0.25)
        #expect(effect.duration == 0.5)
        #expect(effect.events.contains(.add) == insertion)
        #expect(effect.events.contains(.remove) == removal)
        var flagged = effect
        flagged.flags = .init(rawValue: 0x80)
        #expect(flagged.removeInverts(true).flags.rawValue == 0x81)
        #expect(flagged.removeInverts(true).removeInverts(false) == flagged)
    }

    @Test
    func groupResolvesEnvironmentWithoutChangingIt() {
        var environment = EnvironmentValues()
        environment.contentTransition = .opacity
        environment.contentTransitionStyle = .sessionWidget
        environment.layoutDirection = .rightToLeft
        environment.contentTransitionAddsDrawingGroup = true
        let state = environment.contentTransitionGroupEffect.state
        #expect(state.transition.style == .sessionWidget)
        #expect(state.options == [.formsGroup, .addsDrawingGroup])
        #expect(environment.contentTransition.style == nil)
        #expect(environment.contentTransitionState.options == .addsDrawingGroup)
    }

    @Test(.disabled(if: attributeGraphVendor == .oag))
    func implicitEffectResolvesDefaultsAndTracksEnvironment() {
        let graph = Graph()
        let subgraph = Subgraph(graph: graph)
        defer { subgraph.invalidate() }
        subgraph.apply {
            var environment = EnvironmentValues()
            environment.contentTransition.style = .sessionWidget
            environment.contentTransitionStyle = .animatedWidget
            environment.contentTransitionAnimation = .linear
            environment.contentTransitionAddsDrawingGroup = true
            environment.layoutDirection = .rightToLeft
            let source = Attribute(value: environment)
            let effect = Attribute(ContentTransitionEffect.Init(
                environment: source, defaultTransition: .interpolate
            ))
            let initial = effect.value.state
            #expect(initial.transition.isNamed(.diff))
            #expect(initial.transition.isReplaceable)
            #expect(initial.transition.style == .animatedWidget)
            #expect(initial.style == .animatedWidget)
            #expect(initial.animation == .linear)
            #expect(initial.options == [.addsDrawingGroup, .implicitGroup])
            if case let .named(named) = initial.transition.storage {
                #expect(named.layoutDirection == .rightToLeft)
            } else {
                Issue.record("Expected a named transition")
            }
            #expect(source.value.contentTransition.isNamed(.default))
            #expect(source.value.contentTransition.style == .sessionWidget)

            environment.contentTransition = .identity
            source.value = environment
            #expect(effect.value.state.transition.isNamed(.identity))
            #expect(!effect.value.state.transition.isReplaceable)

            environment.contentTransition = .init(method: .binary, effects: [.init(.opacity)])
            source.value = environment
            if case let .custom(custom) = effect.value.state.transition.storage {
                #expect(custom.layoutDirection == .rightToLeft)
            } else {
                Issue.record("Expected a custom transition")
            }
            #expect(!effect.value.state.transition.isReplaceable)
        }
    }

    @Test(.disabled(if: attributeGraphVendor == .oag))
    func characterOrderRequestsTextLayoutManager() {
        let graph = Graph()
        let subgraph = Subgraph(graph: graph)
        defer { subgraph.invalidate() }
        subgraph.apply {
            let view = CharacterOrderProbe().contentTransitionPrefersCharacterOrder()
            func makeView<V: View>(_ view: V) {
                _ = V._makeView(view: .init(Attribute(value: view)), inputs: .invalidInputs(.invalid))
            }
            makeView(view)
        }
    }

    @Test(.disabled(if: attributeGraphVendor == .oag))
    func groupProducesTransitionDisplayList() {
        let content = Color.red.frame(width: 32, height: 48)
            .contentTransitionGroup().contentTransition(.opacity)
        Update.perform {
            let graph = ViewGraph(rootViewType: type(of: content), requestedOutputs: [.layout, .displayList])
            defer { graph.invalidate() }
            graph.setRootView(content)
            #expect(graph.sizeThatFits(.unspecified) == CGSize(width: 32, height: 48))
            graph.instantiate()
            let (list, _) = graph.displayList()
            func findState(in list: DisplayList) -> ContentTransition.State? {
                for item in list.items {
                    if case let .effect(effect, content) = item.value {
                        if case let .contentTransition(state) = effect { return state }
                        if let state = findState(in: content) { return state }
                    }
                }
                return nil
            }
            let state = findState(in: list)
            #expect(state?.transition.isNamed(.opacity) == true)
            #expect(state?.options.contains(.formsGroup) == true)
        }
    }

    @Test(.disabled(if: attributeGraphVendor == .oag))
    func modifierPropagatesUpdatesAndOnlyInheritedOptions() {
        let graph = Graph()
        let subgraph = Subgraph(graph: graph)
        defer { subgraph.invalidate() }
        subgraph.apply {
            var environment = EnvironmentValues()
            environment.contentTransitionState = .init(
                transition: .interpolate, style: .sessionWidget, animation: .linear,
                options: [.addsDrawingGroup, .formsGroup, .implicitGroup, .animatesDifferentContent]
            )
            let source = Attribute(value: environment)
            let modifier = Attribute(value: _ContentTransitionModifier(transition: .opacity, animation: nil, options: []))
            var inputs = _ViewInputs.invalidInputs(.invalid)
            inputs.environment = source
            var child = source
            _ = _ContentTransitionModifier._makeView(modifier: .init(modifier), inputs: inputs) { _, inputs in
                child = inputs.environment
                return _ViewOutputs()
            }
            #expect(child.value.contentTransitionState == .init(
                transition: .opacity, style: .sessionWidget, options: .addsDrawingGroup
            ))
            modifier.value = .init(transition: .identity, animation: .easeIn, options: .animatesDifferentContent)
            #expect(child.value.contentTransitionState == .init(
                transition: .identity, style: .sessionWidget, animation: .easeIn,
                options: [.addsDrawingGroup, .animatesDifferentContent]
            ))
            #expect(source.value.contentTransition == .interpolate)
        }
    }
}

private struct CharacterOrderProbe: PrimitiveView {
    nonisolated static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        #expect(inputs.prefersTextLayoutManager)
        return _ViewOutputs()
    }
}
