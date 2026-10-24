//
//  SymbolEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C350E1C6FA5CB264BFEA1DF73B9E8FA7 (SwiftUI)

import OpenAttributeGraphShims
@_spi(Private) public import OpenSwiftUICore

// MARK: - SymbolEffect

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
public struct SymbolEffect: Equatable {
    package var base: _SymbolEffect

    package init(base: _SymbolEffect) {
        self.base = base
    }

    @available(OpenSwiftUI_v6_0, *)
    public func speed(_ speed: Double) -> SymbolEffect {
        var effect = self
        effect.base.options.speed = Float(speed)
        return effect
    }

    @available(OpenSwiftUI_v6_0, *)
    public func repeatCount(_ value: Double?) -> SymbolEffect {
        var effect = self
        effect.base.options.repeatCount = value.map { Float($0) }
        return effect
    }

    @available(OpenSwiftUI_v6_0, *)
    public func repeatDelay(_ value: Double?) -> SymbolEffect {
        var effect = self
        effect.base.options.repeatDelay = value.map { Float($0) }
        return effect
    }

    // MARK: - Pulse

    public struct PulseConfiguration: Equatable {
        package var base: _SymbolEffect.PulseConfiguration

        package init(base: _SymbolEffect.PulseConfiguration) {
            self.base = base
        }

        public static var `default`: SymbolEffect.PulseConfiguration {
            .init(base: .init())
        }

        @available(*, deprecated, message: "no longer supported")
        public static var slow: SymbolEffect.PulseConfiguration {
            .init(base: .init())
        }

        @available(*, deprecated, message: "no longer supported")
        public static var fast: SymbolEffect.PulseConfiguration {
            .init(base: .init())
        }

        public static var byLayer: SymbolEffect.PulseConfiguration {
            .init(base: .init())
        }

        public static var wholeSymbol: SymbolEffect.PulseConfiguration {
            var base = _SymbolEffect.PulseConfiguration()
            base.layered = false
            return .init(base: base)
        }

        public var byLayer: SymbolEffect.PulseConfiguration {
            var configuration = self
            configuration.base.layered = true
            return configuration
        }

        public var wholeSymbol: SymbolEffect.PulseConfiguration {
            var configuration = self
            configuration.base.layered = false
            return configuration
        }
    }

    public static func pulse(_ config: SymbolEffect.PulseConfiguration = .default) -> SymbolEffect {
        SymbolEffect(base: _SymbolEffect(.pulse(config.base)))
    }

    public static var pulse: SymbolEffect {
        SymbolEffect(base: _SymbolEffect(.pulse(.init())))
    }

    // MARK: - Breathe

    @available(OpenSwiftUI_v6_0, *)
    public struct BreatheConfiguration: Equatable {
        package var base: _SymbolEffect.BreatheConfiguration

        package init(base: _SymbolEffect.BreatheConfiguration) {
            self.base = base
        }

        public static var `default`: SymbolEffect.BreatheConfiguration {
            .init(base: .init())
        }

        public var onlyScale: SymbolEffect.BreatheConfiguration {
            var base = _SymbolEffect.BreatheConfiguration()
            base.flags.insert(.onlyScale)
            return .init(base: base)
        }

        public static var wholeSymbol: SymbolEffect.BreatheConfiguration {
            var base = _SymbolEffect.BreatheConfiguration()
            base.layered = false
            return .init(base: base)
        }

        public var byLayer: SymbolEffect.BreatheConfiguration {
            var configuration = self
            configuration.base.layered = true
            return configuration
        }

        public var wholeSymbol: SymbolEffect.BreatheConfiguration {
            var configuration = self
            configuration.base.layered = false
            return configuration
        }
    }

    @available(OpenSwiftUI_v6_0, *)
    public static func breathe(_ config: SymbolEffect.BreatheConfiguration = .default) -> SymbolEffect {
        SymbolEffect(base: _SymbolEffect(.breathe(config.base)))
    }

    @available(OpenSwiftUI_v6_0, *)
    public static var breathe: SymbolEffect {
        SymbolEffect(base: _SymbolEffect(.breathe(.init())))
    }

    // MARK: - Bounce

    public struct BounceConfiguration: Equatable {
        package var base: _SymbolEffect.BounceConfiguration

        package init(base: _SymbolEffect.BounceConfiguration) {
            self.base = base
        }

        public static var `default`: SymbolEffect.BounceConfiguration {
            .init(base: .init())
        }

        public static var up: SymbolEffect.BounceConfiguration {
            var base = _SymbolEffect.BounceConfiguration()
            base.flags = .up
            return .init(base: base)
        }

        public static var down: SymbolEffect.BounceConfiguration {
            var base = _SymbolEffect.BounceConfiguration()
            base.flags = .down
            return .init(base: base)
        }

        public static var byLayer: SymbolEffect.BounceConfiguration {
            .init(base: .init())
        }

        public static var wholeSymbol: SymbolEffect.BounceConfiguration {
            var base = _SymbolEffect.BounceConfiguration()
            base.layered = false
            return .init(base: base)
        }

        public var byLayer: SymbolEffect.BounceConfiguration {
            var configuration = self
            configuration.base.layered = true
            return configuration
        }

        public var wholeSymbol: SymbolEffect.BounceConfiguration {
            var configuration = self
            configuration.base.layered = false
            return configuration
        }
    }

    public static func bounce<T>(
        _ config: SymbolEffect.BounceConfiguration = .default,
        value: T
    ) -> SymbolEffect where T: Equatable {
        var base = config.base
        base.trigger = .value(AnyEquatable(value))
        return SymbolEffect(base: _SymbolEffect(.bounce(base)))
    }

    @available(OpenSwiftUI_v6_0, *)
    public static func bounce(_ config: SymbolEffect.BounceConfiguration = .default) -> SymbolEffect {
        SymbolEffect(base: _SymbolEffect(.bounce(config.base)))
    }

    // MARK: - Wiggle

    @available(OpenSwiftUI_v6_0, *)
    public struct WiggleConfiguration: Equatable {
        package var base: _SymbolEffect.WiggleConfiguration

        package init(base: _SymbolEffect.WiggleConfiguration) {
            self.base = base
        }

        public static var `default`: SymbolEffect.WiggleConfiguration {
            .init(base: .init())
        }

        public static func linear(angle: Angle) -> SymbolEffect.WiggleConfiguration {
            var base = _SymbolEffect.WiggleConfiguration()
            base.angle = angle
            return .init(base: base)
        }

        public static var rotational: SymbolEffect.WiggleConfiguration {
            var base = _SymbolEffect.WiggleConfiguration()
            base.flags = .rotational
            return .init(base: base)
        }

        public func continuous(_ enabled: Bool = true) -> SymbolEffect.WiggleConfiguration {
            var configuration = self
            if enabled {
                configuration.base.flags.insert(.continuous)
            } else {
                configuration.base.flags.remove(.continuous)
            }
            return configuration
        }

        public func byLayer(_ enabled: Bool) -> SymbolEffect.WiggleConfiguration {
            var configuration = self
            configuration.base.layered = enabled
            return configuration
        }
    }

    @available(OpenSwiftUI_v6_0, *)
    public static func wiggle(_ config: SymbolEffect.WiggleConfiguration = .default) -> SymbolEffect {
        SymbolEffect(base: _SymbolEffect(.wiggle(config.base)))
    }

    @available(OpenSwiftUI_v6_0, *)
    public static func wiggle<T>(
        _ config: SymbolEffect.WiggleConfiguration = .default,
        value: T
    ) -> SymbolEffect where T: Equatable {
        var base = config.base
        base.trigger = .value(AnyEquatable(value))
        return SymbolEffect(base: _SymbolEffect(.wiggle(base)))
    }

    // MARK: - Rotate

    @available(OpenSwiftUI_v6_0, *)
    public struct RotateConfiguration: Equatable {
        package var base: _SymbolEffect.RotateConfiguration

        package init(base: _SymbolEffect.RotateConfiguration) {
            self.base = base
        }

        public static var `default`: SymbolEffect.RotateConfiguration {
            .init(base: .init())
        }

        public static var clockwise: SymbolEffect.RotateConfiguration {
            var base = _SymbolEffect.RotateConfiguration()
            base.flags = .clockwise
            return .init(base: base)
        }

        public static var counterClockwise: SymbolEffect.RotateConfiguration {
            var base = _SymbolEffect.RotateConfiguration()
            base.flags = .counterClockwise
            return .init(base: base)
        }

        public func continuous(_ enabled: Bool = true) -> SymbolEffect.RotateConfiguration {
            var configuration = self
            if enabled {
                configuration.base.flags.insert(.continuous)
            } else {
                configuration.base.flags.remove(.continuous)
            }
            return configuration
        }

        public func byLayer(_ enabled: Bool) -> SymbolEffect.RotateConfiguration {
            var configuration = self
            configuration.base.layered = enabled
            return configuration
        }
    }

    @available(OpenSwiftUI_v6_0, *)
    public static func rotate(_ config: SymbolEffect.RotateConfiguration = .default) -> SymbolEffect {
        SymbolEffect(base: _SymbolEffect(.rotate(config.base)))
    }

    @available(OpenSwiftUI_v6_0, *)
    public static func rotate<T>(
        _ config: SymbolEffect.RotateConfiguration = .default,
        value: T
    ) -> SymbolEffect where T: Equatable {
        var base = config.base
        base.trigger = .value(AnyEquatable(value))
        return SymbolEffect(base: _SymbolEffect(.rotate(base)))
    }

    // MARK: - VariableColor

    public struct VariableColorConfiguration: Equatable {
        package var base: _SymbolEffect.VariableColorConfiguration

        package init(base: _SymbolEffect.VariableColorConfiguration) {
            self.base = base
        }

        public static var `default`: SymbolEffect.VariableColorConfiguration {
            .init(base: .init())
        }

        public static var cumulative: SymbolEffect.VariableColorConfiguration {
            .init(base: .init())
        }

        public static var sequential: SymbolEffect.VariableColorConfiguration {
            var base = _SymbolEffect.VariableColorConfiguration()
            base.flags = .iterative
            return .init(base: base)
        }

        public var reversing: SymbolEffect.VariableColorConfiguration {
            var configuration = self
            configuration.base.flags.insert(.reversing)
            return configuration
        }

        public var nonReversing: SymbolEffect.VariableColorConfiguration {
            var configuration = self
            configuration.base.flags.remove(.reversing)
            return configuration
        }

        public var hideOn: SymbolEffect.VariableColorConfiguration {
            var configuration = self
            configuration.base.flags.insert(.hideInactiveLayers)
            return configuration
        }

        public var hideOff: SymbolEffect.VariableColorConfiguration {
            var configuration = self
            configuration.base.flags.remove(.hideInactiveLayers)
            return configuration
        }
    }

    public static func variableColor(_ config: SymbolEffect.VariableColorConfiguration = .default) -> SymbolEffect {
        SymbolEffect(base: _SymbolEffect(.variableColor(config.base)))
    }

    // MARK: - Scale

    public struct ScaleConfiguration: Equatable {
        package var base: _SymbolEffect.ScaleConfiguration

        package init(base: _SymbolEffect.ScaleConfiguration) {
            self.base = base
        }

        public static var none: SymbolEffect.ScaleConfiguration {
            .init(base: .init())
        }

        public static var up: SymbolEffect.ScaleConfiguration {
            var base = _SymbolEffect.ScaleConfiguration()
            base.level = .up
            return .init(base: base)
        }

        public static var down: SymbolEffect.ScaleConfiguration {
            var base = _SymbolEffect.ScaleConfiguration()
            base.level = .down
            return .init(base: base)
        }

        public var byLayer: SymbolEffect.ScaleConfiguration {
            var configuration = self
            configuration.base.layered = true
            return configuration
        }

        public var wholeSymbol: SymbolEffect.ScaleConfiguration {
            var configuration = self
            configuration.base.layered = false
            return configuration
        }
    }

    public static func scale(_ config: SymbolEffect.ScaleConfiguration) -> SymbolEffect {
        SymbolEffect(base: _SymbolEffect(.scale(config.base)))
    }

    @_alwaysEmitIntoClient
    public static var scaleUp: SymbolEffect {
        scale(.up)
    }

    @_alwaysEmitIntoClient
    public static var scaleDown: SymbolEffect {
        scale(.down)
    }

    // MARK: - Hidden

    public struct HiddenConfiguration: Equatable {
        package var base: _SymbolEffect.HiddenConfiguration

        package init(base: _SymbolEffect.HiddenConfiguration) {
            self.base = base
        }

        public static var `default`: SymbolEffect.HiddenConfiguration {
            .init(base: .init())
        }

        public static var down: SymbolEffect.HiddenConfiguration {
            var base = _SymbolEffect.HiddenConfiguration()
            base.flags = .down
            return .init(base: base)
        }

        public static var up: SymbolEffect.HiddenConfiguration {
            var base = _SymbolEffect.HiddenConfiguration()
            base.flags = .up
            return .init(base: base)
        }

        public static var byLayer: SymbolEffect.HiddenConfiguration {
            .init(base: .init())
        }

        public static var wholeSymbol: SymbolEffect.HiddenConfiguration {
            var base = _SymbolEffect.HiddenConfiguration()
            base.layered = false
            return .init(base: base)
        }

        public var byLayer: SymbolEffect.HiddenConfiguration {
            var configuration = self
            configuration.base.layered = true
            return configuration
        }

        public var wholeSymbol: SymbolEffect.HiddenConfiguration {
            var configuration = self
            configuration.base.layered = false
            return configuration
        }
    }

    public static func hidden(
        _ isHidden: Bool = true,
        _ config: SymbolEffect.HiddenConfiguration = .default
    ) -> SymbolEffect {
        var base = config.base
        base.isHidden = isHidden
        return SymbolEffect(base: _SymbolEffect(.hidden(base)))
    }

    // MARK: - Replace

    public struct ReplaceConfiguration: Equatable {
        package var base: _SymbolEffect.ReplaceConfiguration

        package init(base: _SymbolEffect.ReplaceConfiguration) {
            self.base = base
        }

        public static var `default`: SymbolEffect.ReplaceConfiguration {
            .init(base: .init())
        }

        public static var up: SymbolEffect.ReplaceConfiguration {
            var base = _SymbolEffect.ReplaceConfiguration()
            base.flags = .up
            return .init(base: base)
        }

        public static var down: SymbolEffect.ReplaceConfiguration {
            var base = _SymbolEffect.ReplaceConfiguration()
            base.flags = .down
            return .init(base: base)
        }

        public static var offUp: SymbolEffect.ReplaceConfiguration {
            var base = _SymbolEffect.ReplaceConfiguration()
            base.flags = .offUp
            return .init(base: base)
        }

        public static var byLayer: SymbolEffect.ReplaceConfiguration {
            .init(base: .init())
        }

        public static var wholeSymbol: SymbolEffect.ReplaceConfiguration {
            var base = _SymbolEffect.ReplaceConfiguration()
            base.layered = false
            return .init(base: base)
        }

        public var byLayer: SymbolEffect.ReplaceConfiguration {
            var configuration = self
            configuration.base.layered = true
            return configuration
        }

        public var wholeSymbol: SymbolEffect.ReplaceConfiguration {
            var configuration = self
            configuration.base.layered = false
            return configuration
        }

        @available(OpenSwiftUI_v6_0, *)
        public var noSlashes: SymbolEffect.ReplaceConfiguration {
            var configuration = self
            configuration.base.flags.insert(.noSlashes)
            return configuration
        }

        @available(OpenSwiftUI_v6_0, *)
        public var noBadges: SymbolEffect.ReplaceConfiguration {
            var configuration = self
            configuration.base.flags.insert(.noBadges)
            return configuration
        }
    }
}

@_spi(Private)
@available(*, unavailable)
extension SymbolEffect: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SymbolEffect.PulseConfiguration: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SymbolEffect.BreatheConfiguration: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SymbolEffect.BounceConfiguration: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SymbolEffect.WiggleConfiguration: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SymbolEffect.RotateConfiguration: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SymbolEffect.VariableColorConfiguration: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SymbolEffect.ScaleConfiguration: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SymbolEffect.HiddenConfiguration: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SymbolEffect.ReplaceConfiguration: Sendable {}

// MARK: - View + symbolEffect

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension View {
    @_alwaysEmitIntoClient
    nonisolated public func symbolEffect(_ effect: SymbolEffect?) -> some View {
        modifier(_SymbolEffectModifier(effect: effect))
    }
}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension View {
    @_alwaysEmitIntoClient
    nonisolated public func symbolEffects(_ effects: [SymbolEffect]) -> some View {
        modifier(_SymbolEffectsModifier(effects: effects))
    }
}

@available(OpenSwiftUI_v5_0, *)
extension View {
    @_alwaysEmitIntoClient
    nonisolated public func symbolEffectsRemoved(_ isEnabled: Bool = true) -> some View {
        modifier(_SymbolEffectsRemovedModifier(isEnabled: isEnabled))
    }
}

// MARK: - _SymbolEffectModifier

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
@frozen
public struct _SymbolEffectModifier: ViewModifier, PrimitiveViewModifier, _GraphInputsModifier {
    @usableFromInline
    package var effect: SymbolEffect?

    @usableFromInline
    package init(effect: SymbolEffect?) {
        self.effect = effect
    }

    public static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        inputs.environment = Attribute(
            EffectEnvironment(
                modifier: modifier.value,
                environment: inputs.environment,
                identifier: Int(makeUniqueID())
            )
        )
    }

    private struct EffectEnvironment: Rule, AsyncAttribute {
        @Attribute var modifier: _SymbolEffectModifier
        @Attribute var environment: EnvironmentValues
        let identifier: Int

        var value: EnvironmentValues {
            var environment = environment
            if let effect = modifier.effect {
                environment.appendSymbolEffect(effect.base, for: identifier)
            }
            return environment
        }
    }
}

@_spi(Private)
@available(*, unavailable)
extension _SymbolEffectModifier: Sendable {}

// MARK: - _SymbolEffectsModifier

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
@frozen
public struct _SymbolEffectsModifier: ViewModifier, PrimitiveViewModifier, _GraphInputsModifier {
    @usableFromInline
    var effects: [SymbolEffect]

    @_alwaysEmitIntoClient
    init(effects: [SymbolEffect]) {
        self.effects = effects
    }

    public static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        inputs.environment = Attribute(
            EffectsEnvironment(
                modifier: modifier.value,
                environment: inputs.environment,
                identifier: Int(makeUniqueID())
            )
        )
    }

    private struct EffectsEnvironment: Rule, AsyncAttribute {
        @Attribute var modifier: _SymbolEffectsModifier
        @Attribute var environment: EnvironmentValues
        let identifier: Int

        var value: EnvironmentValues {
            var environment = environment
            let effects = modifier.effects
            guard !effects.isEmpty else {
                return environment
            }
            var symbolEffects = environment.symbolEffects
            for (offset, effect) in effects.enumerated() {
                symbolEffects.append(
                    .init(identifier: identifier, serial: offset, effect: effect.base)
                )
            }
            environment.symbolEffects = symbolEffects
            return environment
        }
    }
}

@_spi(Private)
@available(*, unavailable)
extension _SymbolEffectsModifier: Sendable {}

// MARK: - _SymbolEffectsRemovedModifier

@available(OpenSwiftUI_v5_0, *)
@frozen
public struct _SymbolEffectsRemovedModifier: ViewModifier, PrimitiveViewModifier, _GraphInputsModifier {
    @usableFromInline
    var isEnabled: Bool

    @_alwaysEmitIntoClient
    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    public static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        inputs.environment = Attribute(
            EffectEnvironment(
                modifier: modifier.value,
                environment: inputs.environment
            )
        )
    }

    private struct EffectEnvironment: Rule, AsyncAttribute {
        @Attribute var modifier: _SymbolEffectsRemovedModifier
        @Attribute var environment: EnvironmentValues

        var value: EnvironmentValues {
            var environment = environment
            if modifier.isEnabled {
                environment.symbolEffects = []
            }
            return environment
        }
    }
}

@available(*, unavailable)
extension _SymbolEffectsRemovedModifier: Sendable {}

// MARK: - SymbolEffect.HiddenTransition

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension Transition where Self == SymbolEffect.HiddenTransition {
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static func symbolHidden(_ config: SymbolEffect.HiddenConfiguration = .default) -> SymbolEffect.HiddenTransition {
        .init(config: config)
    }
}

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension SymbolEffect {
    @MainActor
    @preconcurrency
    public struct HiddenTransition: Transition {
        public var config: SymbolEffect.HiddenConfiguration

        public init(config: SymbolEffect.HiddenConfiguration) {
            self.config = config
        }

        public func body(content: Content, phase: TransitionPhase) -> some View {
            var config = config
            config.base.isHidden = !phase.isIdentity
            let effect = SymbolEffect(base: _SymbolEffect(.hidden(config.base)))
            return content.modifier(_SymbolEffectModifier(effect: effect))
        }

        public static let properties = TransitionProperties(hasMotion: true)

        public func _makeContentTransition(transition: inout _Transition_ContentTransition) {
            switch transition.operation {
            case .effects:
                let effect = ContentTransition.Effect(
                    type: ContentTransition.EffectType(
                        type: .symbolAppearDisappear,
                        arg0: .int(config.base.transitionFlags.rawValue),
                        arg1: .float(1)
                    )
                )
                transition.result = .effects([effect])
            case .hasContentTransition:
                transition.result = .bool(true)
            }
        }
    }
}

@_spi(Private)
@available(*, unavailable)
extension SymbolEffect.HiddenTransition: Sendable {}

// MARK: - ContentTransition + symbolReplace

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension ContentTransition {
    public static func symbolReplace(_ config: SymbolEffect.ReplaceConfiguration = .default) -> ContentTransition {
        ContentTransition(storage: .symbolReplace(config.base))
    }
}

// MARK: - SymbolEffect + ProtobufMessage

@_spi(Private)
extension SymbolEffect: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try base.encode(to: &encoder)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self.init(base: try _SymbolEffect(from: &decoder))
    }
}

@_spi(Private)
extension SymbolEffect {
    @available(OpenSwiftUI_v6_0, *)
    public var isIndefinite: Bool {
        base.isIndefinite
    }
}
