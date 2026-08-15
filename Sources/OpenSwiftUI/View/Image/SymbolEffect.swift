//
//  SymbolEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - SymbolEffect

@_spi(Private)
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct SymbolEffect: Equatable {
    package var base: _SymbolEffect

    package init(base: _SymbolEffect) {
        self.base = base
    }
}
