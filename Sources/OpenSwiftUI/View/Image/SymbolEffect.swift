//
//  SymbolEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Empty
//  ID: C350E1C6FA5CB264BFEA1DF73B9E8FA7 (SwiftUI)

public import OpenSwiftUICore

// MARK: - SymbolEffect [TODO]

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
public struct SymbolEffect: Equatable {
    // TODO: Store the underlying _SymbolEffect and expose the remaining
    // pulse, breathe, bounce, wiggle, rotate, variable color, scale, and
    // replace configurations.

    public struct HiddenConfiguration: Equatable {
        public static var `default`: SymbolEffect.HiddenConfiguration {
            .init()
        }
    }

    public static func hidden(
        _ isHidden: Bool = true,
        _ config: SymbolEffect.HiddenConfiguration = .default
    ) -> SymbolEffect {
        .init()
    }
}

@_spi(Private)
@available(*, unavailable)
extension SymbolEffect.HiddenConfiguration: Sendable {}

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

// MARK: - _SymbolEffectModifier [TODO]

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
        // TODO: Append the effect to the environment symbol effects.
    }
}

@_spi(Private)
@available(*, unavailable)
extension _SymbolEffectModifier: Sendable {}

// MARK: - _SymbolEffectsModifier [TODO]

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
        // TODO: Append the effects to the environment symbol effects.
    }
}

@_spi(Private)
@available(*, unavailable)
extension _SymbolEffectsModifier: Sendable {}

// MARK: - _SymbolEffectsRemovedModifier [TODO]

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
        // TODO: Clear the environment symbol effects when enabled.
    }
}
