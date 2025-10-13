//
//  OpacityEffect.swift
//  OpenSwiftUICore

extension AnyTransition {
    // FIXME
    public static let opacity: AnyTransition = .init(OpacityTransition())
}

extension View {
    func opacity(_ value: Double) -> some View {
        // FIXME
        modifier(EmptyModifier())
    }
}

struct OpacityTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content.opacity(1)
    }
}
