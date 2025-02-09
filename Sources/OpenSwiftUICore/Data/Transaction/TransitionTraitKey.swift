//
//  TransitionTraitKey.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

@usableFromInline
struct CanTransitionTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: Bool { false }
}

@available(*, unavailable)
extension CanTransitionTraitKey: Sendable {}

extension ViewTraitCollection {
    package var canTransition: Bool {
        get { self[CanTransitionTraitKey.self] }
        set { self[CanTransitionTraitKey.self] = newValue }
    }
}
