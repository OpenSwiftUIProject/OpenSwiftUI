//
//  SymbolEffect.swift
//  OpenSwiftUICore
//
//  Status: Empty

import OpenAttributeGraphShims

package struct _SymbolEffect: Equatable {

}

extension _SymbolEffect {
    package struct Identified: Equatable {

    }

    package struct Phase: Equatable {
        package init() {
            // TODO
        }
    }
}

extension EnvironmentValues {
    package var symbolEffects: [_SymbolEffect.Identified] {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }

    package mutating func appendSymbolEffect(
        _ effect: _SymbolEffect,
        for identifier: Int
    ) {
        _openSwiftUIUnimplementedFailure()
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
