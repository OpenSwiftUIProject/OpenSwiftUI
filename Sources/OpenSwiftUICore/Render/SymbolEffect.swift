//
//  SymbolEffect.swift
//  OpenSwiftUICore
//
//  Status: Empty

import OpenAttributeGraphShims
package import OpenRenderBoxShims

package struct _SymbolEffect: Equatable {

    package init() {}

    package struct ReplaceConfiguration: Equatable {
        package init() {
            // TODO
        }
    }
}

extension _SymbolEffect {
    package struct Identified: Equatable {
        package var identifier: Int

        package var serial: Int

        package var effect: _SymbolEffect

        package init(identifier: Int, serial: Int, effect: _SymbolEffect) {
            self.identifier = identifier
            self.serial = serial
            self.effect = effect
        }
    }

    package struct Phase: Equatable {
        package init() {
            // TODO
        }
    }
}

extension EnvironmentValues {
    private struct SymbolEffectsKey: EnvironmentKey {
        static let defaultValue: [_SymbolEffect.Identified] = []
    }

    package var symbolEffects: [_SymbolEffect.Identified] {
        get { self[SymbolEffectsKey.self] }
        set { self[SymbolEffectsKey.self] = newValue }
    }

    package mutating func appendSymbolEffect(
        _ effect: _SymbolEffect,
        for identifier: Int
    ) {
        let serial = (symbolEffects.last?.serial ?? -1) + 1
        symbolEffects.append(
            _SymbolEffect.Identified(
                identifier: identifier,
                serial: serial,
                effect: effect
            )
        )
    }
}

extension GraphicsImage {
    mutating func updateSymbolEffects(
        _ phase: inout _SymbolEffect.Phase,
        environment: EnvironmentValues,
        transaction: Attribute<Transaction>,
        animationsDisabled: Bool
    ) -> ORBSymbolAnimator? {
        _openSwiftUIUnimplementedWarning()
        return nil
    }
}
