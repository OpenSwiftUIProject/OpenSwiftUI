//
//  EvaluateDefaultFocusAction.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 9993DE8943AC71AF21213EB6FCE0DB61 (SwiftUI?)

#if os(macOS)
import OpenSwiftUICore

// MARK: - EvaluateDefaultFocusAction

struct EvaluateDefaultFocusAction: Hashable {
    var namespace: Namespace.ID
    var priority: DefaultFocusEvaluationPriority
    var onEvaluate: (() -> (any BaseFocusResponder)?)?

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.namespace == rhs.namespace
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(namespace)
    }
}

// MARK: - DefaultFocusStateModifier

struct DefaultFocusStateModifier<A>: ViewModifier where A: Hashable {
    var binding: FocusState<A>.Binding
    var value: A
    var priority: DefaultFocusEvaluationPriority
    @Namespace var namespace

    init(binding: FocusState<A>.Binding, value: A, priority: DefaultFocusEvaluationPriority) {
        self.binding = binding
        self.value = value
        self.priority = priority
    }

    func body(content: Content) -> some View {
        content.environment(\.evaluateDefaultFocus, EvaluateDefaultFocusAction(
            namespace: namespace,
            priority: priority,
            onEvaluate: { binding.location.findEntry(with: value)?.responder }
        ))
    }
}

// MARK: - EnvironmentValues + Default Focus

extension EnvironmentValues {
    var evaluateDefaultFocus: EvaluateDefaultFocusAction? {
        get { self[EvaluateDefaultFocusKey.self] }
        set { self[EvaluateDefaultFocusKey.self] = newValue }
    }

    private struct EvaluateDefaultFocusKey: EnvironmentKey {
        static var defaultValue: EvaluateDefaultFocusAction? { nil }
    }
}
#endif
