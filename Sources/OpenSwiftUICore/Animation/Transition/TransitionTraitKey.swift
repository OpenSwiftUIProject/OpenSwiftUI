//
//  TransitionTraitKey.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
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
