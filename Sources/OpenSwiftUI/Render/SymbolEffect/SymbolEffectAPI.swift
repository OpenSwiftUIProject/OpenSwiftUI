//
//  SymbolEffectAPI.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1E42BCA1B3AC632454FB5BE9F835FBCE (SwiftUI)

#if OPENSWIFTUI_LINK_SYMBOLS
import OpenAttributeGraphShims
@_spi(Private) public import OpenSwiftUICore
@_spi(Private) public import Symbols

// MARK: - View + symbolEffect

@available(OpenSwiftUI_v5_0, *)
extension View {
    /// Returns a new view with a symbol effect added to it.
    ///
    /// The following example adds a repeating pulse effect to two
    /// symbol images:
    ///
    ///     VStack {
    ///         Image(systemName: "bolt.slash.fill")
    ///         Image(systemName: "folder.fill.badge.person.crop")
    ///     }
    ///     .symbolEffect(.pulse)
    ///
    /// - Parameters:
    ///   - effect: A symbol effect to add to the view. Existing effects
    ///     added by ancestors of the view are preserved, but may be
    ///     overridden by the new effect. Added effects will be applied
    ///     to the ``Image`` views contained by the child view.
    ///   - isActive: whether the effect is active or inactive.
    ///
    /// - Returns: a copy of the view with a symbol effect added.
    @_alwaysEmitIntoClient
    nonisolated public func symbolEffect<T>(
        _ effect: T,
        options: SymbolEffectOptions = .default,
        isActive: Bool = true
    ) -> some View where T: IndefiniteSymbolEffect, T: Symbols.SymbolEffect {
        modifier(_IndefiniteSymbolEffectModifier(
            effect: effect, options: options, isActive: isActive))
    }

    /// Returns a new view with a symbol effect added to it.
    ///
    /// The following example adds a bounce effect to two symbol
    /// images, the animation will play each time `counter` changes:
    ///
    ///     VStack {
    ///         Image(systemName: "bolt.slash.fill")
    ///         Image(systemName: "folder.fill.badge.person.crop")
    ///     }
    ///     .symbolEffect(.bounce, value: counter)
    ///
    /// - Parameters:
    ///   - effect: A symbol effect to add to the view. Existing effects
    ///     added by ancestors of the view are preserved, but may be
    ///     overridden by the new effect. Added effects will be applied
    ///     to the ``Image`` views contained by the child view.
    ///   - value: the value to monitor for changes, the animation is
    ///     triggered each time the value changes.
    ///
    /// - Returns: a copy of the view with a symbol effect added.
    @_alwaysEmitIntoClient
    nonisolated public func symbolEffect<T, U>(
        _ effect: T,
        options: SymbolEffectOptions = .default,
        value: U
    ) -> some View where T: DiscreteSymbolEffect, T: Symbols.SymbolEffect, U: Equatable {
        modifier(_DiscreteSymbolEffectModifier(
            effect: effect, options: options, value: value))
    }
}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension View {
    @_alwaysEmitIntoClient
    nonisolated public func symbolEffect<T>(
        _ effect: T,
        options: SymbolEffectOptions = .default,
        when condition: Bool
    ) -> some View where T: DiscreteSymbolEffect, T: Symbols.SymbolEffect {
        modifier(_ConditionalSymbolEffectModifier(
            effect: effect, options: options, condition: condition))
    }
}

// MARK: - _IndefiniteSymbolEffectModifier

@available(OpenSwiftUI_v5_0, *)
@frozen
public struct _IndefiniteSymbolEffectModifier: ViewModifier, PrimitiveViewModifier, _GraphInputsModifier {
    @usableFromInline
    var config: SymbolEffectConfiguration

    @usableFromInline
    var options: SymbolEffectOptions

    @usableFromInline
    var isActive: Bool

    @_alwaysEmitIntoClient
    init<T>(
        effect: T,
        options: SymbolEffectOptions,
        isActive: Bool
    ) where T: IndefiniteSymbolEffect, T: Symbols.SymbolEffect {
        self.config = effect.configuration
        self.options = options
        self.isActive = isActive
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
        @Attribute var modifier: _IndefiniteSymbolEffectModifier
        @Attribute var environment: EnvironmentValues
        let identifier: Int

        var value: EnvironmentValues {
            var environment = environment
            guard modifier.isActive,
                  let effect = _SymbolEffect(config: modifier.config, options: modifier.options)
            else {
                return environment
            }
            environment.appendSymbolEffect(effect, for: identifier)
            return environment
        }
    }
}

@available(*, unavailable)
extension _IndefiniteSymbolEffectModifier: Sendable {}

// MARK: - _DiscreteSymbolEffectModifier

@available(OpenSwiftUI_v5_0, *)
@frozen
public struct _DiscreteSymbolEffectModifier<T>: ViewModifier, PrimitiveViewModifier, _GraphInputsModifier where T: Equatable {
    @usableFromInline
    var config: SymbolEffectConfiguration

    @usableFromInline
    var options: SymbolEffectOptions

    @usableFromInline
    var value: T

    @_alwaysEmitIntoClient
    init<U>(
        effect: U,
        options: SymbolEffectOptions,
        value: T
    ) where U: DiscreteSymbolEffect, U: Symbols.SymbolEffect {
        config = effect.configuration
        self.options = options
        self.value = value
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
        @Attribute var modifier: _DiscreteSymbolEffectModifier
        @Attribute var environment: EnvironmentValues
        let identifier: Int

        var value: EnvironmentValues {
            var environment = environment
            let modifier = modifier
            guard let effect = _SymbolEffect(
                config: modifier.config,
                options: modifier.options,
                trigger: .value(AnyEquatable(modifier.value))
            ) else {
                return environment
            }
            environment.appendSymbolEffect(effect, for: identifier)
            return environment
        }
    }
}

@available(*, unavailable)
extension _DiscreteSymbolEffectModifier: Sendable {}

// MARK: - _ConditionalSymbolEffectModifier

@available(OpenSwiftUI_v6_0, *)
@frozen
public struct _ConditionalSymbolEffectModifier: ViewModifier, PrimitiveViewModifier, _GraphInputsModifier {
    @usableFromInline
    var config: SymbolEffectConfiguration

    @usableFromInline
    var options: SymbolEffectOptions

    @usableFromInline
    var condition: Bool

    @_alwaysEmitIntoClient
    init<U>(
        effect: U,
        options: SymbolEffectOptions,
        condition: Bool
    ) where U: DiscreteSymbolEffect, U: Symbols.SymbolEffect {
        config = effect.configuration
        self.options = options
        self.condition = condition
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
        @Attribute var modifier: _ConditionalSymbolEffectModifier
        @Attribute var environment: EnvironmentValues
        let identifier: Int

        var value: EnvironmentValues {
            var environment = environment
            let modifier = modifier
            guard let effect = _SymbolEffect(
                config: modifier.config,
                options: modifier.options,
                trigger: .condition(modifier.condition)
            ) else {
                return environment
            }
            environment.appendSymbolEffect(effect, for: identifier)
            return environment
        }
    }
}

@available(*, unavailable)
extension _ConditionalSymbolEffectModifier: Sendable {}

// MARK: - SymbolEffectTransition

@available(OpenSwiftUI_v5_0, *)
extension Transition where Self == SymbolEffectTransition {
    /// Creates a transition that applies the provided effect to symbol
    /// images within the inserted or removed view hierarchy. Other
    /// views are unaffected by this transition.
    ///
    /// - Parameter effect: the symbol effect value.
    ///
    /// - Returns: a new transition.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static func symbolEffect<T>(
        _ effect: T,
        options: SymbolEffectOptions = .default
    ) -> SymbolEffectTransition where T: Symbols.SymbolEffect, T: TransitionSymbolEffect {
        SymbolEffectTransition(effect: effect, options: options)
    }

    /// A transition that applies the default symbol effect transition
    /// to symbol images within the inserted or removed view hierarchy.
    /// Other views are unaffected by this transition.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var symbolEffect: SymbolEffectTransition {
        symbolEffect(.automatic)
    }
}

/// Creates a transition that applies the Appear or Disappear
/// symbol animation to symbol images within the inserted or
/// removed view hierarchy.
///
/// Other views are unaffected by this transition.
@available(OpenSwiftUI_v5_0, *)
@frozen
@MainActor
@preconcurrency
public struct SymbolEffectTransition: Transition {
    @usableFromInline
    var config: SymbolEffectConfiguration

    @usableFromInline
    var options: SymbolEffectOptions

    @_alwaysEmitIntoClient
    public init<T>(
        effect: T,
        options: SymbolEffectOptions
    ) where T: Symbols.SymbolEffect, T: TransitionSymbolEffect {
        config = effect.configuration
        self.options = options
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        var effect: SymbolEffect?
        if let hidden = _SymbolEffect.HiddenConfiguration(config, hidden: !phase.isIdentity) {
            effect = SymbolEffect(
                base: _SymbolEffect(.hidden(hidden), options: _SymbolEffect.Options(options))
            )
        }
        return content.modifier(_SymbolEffectModifier(effect: effect))
    }

    public static let properties = TransitionProperties(hasMotion: true)

    public func _makeContentTransition(transition: inout _Transition_ContentTransition) {
        switch transition.operation {
        case .effects:
            guard let hidden = _SymbolEffect.HiddenConfiguration(config, hidden: true) else {
                return
            }
            let effect = ContentTransition.Effect(
                type: ContentTransition.EffectType(
                    type: .symbolAppearDisappear,
                    arg0: .int(hidden.transitionFlags.rawValue),
                    arg1: .float(_SymbolEffect.Options(options).speed)
                )
            )
            transition.result = .effects([effect])
        case .hasContentTransition:
            if _SymbolEffect.HiddenConfiguration(config, hidden: true) != nil {
                transition.result = .bool(true)
            }
        }
    }
}

@available(*, unavailable)
extension SymbolEffectTransition: Sendable {}

// MARK: - ContentTransition + symbolEffect

@available(OpenSwiftUI_v5_0, *)
extension ContentTransition {
    /// Creates a content transition that applies the symbol Replace
    /// animation to symbol images that it is applied to.
    ///
    /// - Parameter effect: the animation configuration value.
    ///
    /// - Returns: a new content transition.
    public static func symbolEffect<T>(
        _ effect: T,
        options: SymbolEffectOptions = .default
    ) -> ContentTransition where T: ContentTransitionSymbolEffect, T: Symbols.SymbolEffect {
        guard let config = _SymbolEffect.ReplaceConfiguration(effect.configuration, options: options) else {
            return .default
        }
        return ContentTransition(storage: .symbolReplace(config))
    }

    /// A content transition that applies the default symbol effect
    /// transition to symbol images within the inserted or removed view
    /// hierarchy. Other views are unaffected by this transition.
    @_alwaysEmitIntoClient
    public static var symbolEffect: ContentTransition {
        symbolEffect(.automatic)
    }
}

// MARK: - WiggleSymbolEffect + Angle

extension WiggleSymbolEffect {
    /// Returns a copy of the effect requesting an animation that moves
    /// back and forth along an axis with the passed in angle.
    @available(OpenSwiftUI_v6_0, *)
    @_alwaysEmitIntoClient
    public func custom(angle: Angle) -> WiggleSymbolEffect {
        custom(angle: angle.degrees)
    }
}

// MARK: - _SymbolEffect + Symbols

extension _SymbolEffect {
    fileprivate init?(config: SymbolEffectConfiguration, options: SymbolEffectOptions) {
        let storage: Storage
        switch config.effect {
        case let .pulse(effect):
            var value = PulseConfiguration()
            value.layered = effect.isLayered ?? true
            storage = .pulse(value)
        case let .bounce(effect):
            storage = .bounce(BounceConfiguration(
                effect,
                isContinuous: options.repeat == nil || options.prefersContinuous,
                trigger: nil
            ))
        case let .variableColor(effect):
            storage = .variableColor(VariableColorConfiguration(effect, trigger: nil))
        case let .scale(effect):
            var value = ScaleConfiguration()
            value.layered = effect.isLayered ?? true
            if let isUp = effect.isUp {
                value.level = isUp ? .up : .down
            }
            storage = .scale(value)
        case let .appear(effect):
            var value = HiddenConfiguration()
            value.layered = effect.isLayered ?? true
            if let isUp = effect.isUp {
                value.flags = isUp ? .down : .up
            }
            value.isHidden = true
            storage = .hidden(value)
        case let .disappear(effect):
            var value = HiddenConfiguration()
            value.layered = effect.isLayered ?? true
            if let isUp = effect.isUp {
                value.flags = isUp ? .up : .down
            }
            value.isHidden = true
            storage = .hidden(value)
        case let .wiggle(effect):
            storage = .wiggle(WiggleConfiguration(
                effect,
                isContinuous: options.repeat == nil || options.prefersContinuous,
                trigger: nil
            ))
        case let .rotate(effect):
            storage = .rotate(RotateConfiguration(
                effect,
                isContinuous: options.repeat == nil || options.prefersContinuous,
                trigger: nil
            ))
        case let .breathe(effect):
            storage = .breathe(BreatheConfiguration(effect, trigger: nil))
        default:
            return nil
        }
        self.init(storage, options: Options(options))
    }

    fileprivate init?(
        config: SymbolEffectConfiguration,
        options: SymbolEffectOptions,
        trigger: _SymbolEffect.Trigger
    ) {
        let storage: Storage
        switch config.effect {
        case let .pulse(effect):
            var value = PulseConfiguration()
            value.layered = effect.isLayered ?? true
            value.trigger = trigger
            storage = .pulse(value)
        case let .bounce(effect):
            storage = .bounce(BounceConfiguration(
                effect,
                isContinuous: options.repeat != nil && options.prefersContinuous,
                trigger: trigger
            ))
        case let .variableColor(effect):
            storage = .variableColor(VariableColorConfiguration(effect, trigger: trigger))
        case let .wiggle(effect):
            storage = .wiggle(WiggleConfiguration(
                effect,
                isContinuous: options.repeat != nil && options.prefersContinuous,
                trigger: trigger
            ))
        case let .rotate(effect):
            storage = .rotate(RotateConfiguration(
                effect,
                isContinuous: options.repeat != nil && options.prefersContinuous,
                trigger: trigger
            ))
        case let .breathe(effect):
            storage = .breathe(BreatheConfiguration(effect, trigger: trigger))
        default:
            return nil
        }
        self.init(storage, options: Options(options))
    }
}

// MARK: - _SymbolEffect.Options + Symbols

extension _SymbolEffect.Options {
    fileprivate init(_ options: SymbolEffectOptions) {
        self.init()
        switch options.repeat {
        case let .count(count):
            repeatCount = Float(count)
        case .indefinite:
            repeatCount = .infinity
        default:
            break
        }
        repeatDelay = options.repeatDelay.map { Float($0) }
        speed = Float(options.speed)
    }
}

// MARK: - _SymbolEffect.HiddenConfiguration + Symbols

extension _SymbolEffect.HiddenConfiguration {
    fileprivate init?(_ config: SymbolEffectConfiguration, hidden: Bool) {
        self.init()
        switch config.effect {
        case let .appear(effect):
            layered = effect.isLayered ?? true
            if let isUp = effect.isUp {
                flags = isUp ? .down : .up
            }
        case let .disappear(effect):
            layered = effect.isLayered ?? true
            if let isUp = effect.isUp {
                flags = isUp ? .up : .down
            }
        case .automatic:
            break
        default:
            return nil
        }
        isHidden = hidden
    }
}

// MARK: - _SymbolEffect.ReplaceConfiguration + Symbols

extension _SymbolEffect.ReplaceConfiguration {
    fileprivate init?(_ config: SymbolEffectConfiguration, options: SymbolEffectOptions) {
        switch config.effect {
        case let .replace(effect):
            self.init(
                effect,
                options: options,
                allowMagic: effect.style == nil && isLinkedOnOrAfter(.v6)
            )
        case .automatic:
            self.init()
            speed = Float(options.speed)
        case let .magicReplace(effect):
            self.init(effect.fallback, options: options, allowMagic: true)
        default:
            return nil
        }
    }
}

// MARK: - _SymbolEffect.BounceConfiguration + Symbols

extension _SymbolEffect.BounceConfiguration {
    fileprivate init(_ effect: BounceSymbolEffect, isContinuous: Bool, trigger: _SymbolEffect.Trigger?) {
        self.init()
        layered = effect.isLayered ?? true
        if isContinuous {
            flags.insert(.continuous)
        }
        if let isUp = effect.isUp {
            flags.insert(isUp ? .up : .down)
        }
        self.trigger = trigger
    }
}

// MARK: - _SymbolEffect.VariableColorConfiguration + Symbols

extension _SymbolEffect.VariableColorConfiguration {
    fileprivate init(_ effect: VariableColorSymbolEffect, trigger: _SymbolEffect.Trigger?) {
        self.init()
        if effect.isReversing == true {
            flags.insert(.reversing)
        }
        if effect.isIterative == true {
            flags.insert(.iterative)
        }
        if effect.hasReveal == true {
            flags.insert(.hideInactiveLayers)
        }
        self.trigger = trigger
    }
}

// MARK: - _SymbolEffect.WiggleConfiguration + Symbols

extension _SymbolEffect.WiggleConfiguration {
    fileprivate init(_ effect: WiggleSymbolEffect, isContinuous: Bool, trigger: _SymbolEffect.Trigger?) {
        self.init()
        layered = effect.isLayered ?? true
        if isContinuous {
            flags.insert(.continuous)
        }
        switch effect.style {
        case let .rotational(forward):
            flags.insert(.rotational)
            flags.insert(forward ? .forward : .backward)
        case let .linear(degrees):
            angle = .degrees(degrees)
        case let .localized(forward):
            flags.insert(.localized)
            flags.insert(forward ? .forward : .backward)
            appliesRTL = true
        default:
            break
        }
        self.trigger = trigger
    }
}

// MARK: - _SymbolEffect.RotateConfiguration + Symbols

extension _SymbolEffect.RotateConfiguration {
    fileprivate init(_ effect: RotateSymbolEffect, isContinuous: Bool, trigger: _SymbolEffect.Trigger?) {
        self.init()
        layered = effect.isLayered ?? true
        if isContinuous {
            flags.insert(.continuous)
        }
        if let isClockwise = effect.isClockwise {
            flags.insert(isClockwise ? .clockwise : .counterClockwise)
        }
        self.trigger = trigger
    }
}

// MARK: - _SymbolEffect.BreatheConfiguration + Symbols

extension _SymbolEffect.BreatheConfiguration {
    fileprivate init(_ effect: BreatheSymbolEffect, trigger: _SymbolEffect.Trigger?) {
        self.init()
        layered = effect.isLayered ?? true
        if case .scale = effect.style {
            flags.insert(.onlyScale)
        }
        self.trigger = trigger
    }
}

// MARK: - _SymbolEffect.ReplaceConfiguration + ReplaceSymbolEffect

extension _SymbolEffect.ReplaceConfiguration {
    fileprivate init(_ effect: ReplaceSymbolEffect, options: SymbolEffectOptions, allowMagic: Bool) {
        self.init()
        layered = effect.isLayered ?? true
        speed = Float(options.speed)
        switch effect.style {
        case .downUp:
            flags.insert(.down)
        case .upUp:
            flags.insert(.up)
        case .offUp:
            flags.insert(.offUp)
        default:
            break
        }
        if !allowMagic {
            flags.insert(.noSlashes)
            flags.insert(.noBadges)
        }
    }
}
#endif
