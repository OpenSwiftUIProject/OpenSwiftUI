//
//  DefaultFocusEvaluationPriority.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

/// Prioritizations for default focus preferences when evaluating where
/// to move focus in different circumstances.
@available(OpenSwiftUI_v4_0, *)
public struct DefaultFocusEvaluationPriority: Sendable {
    let rawValue: Int

    /// Use the default focus preference when focus moves into the affected
    /// branch automatically, but ignore it when the movement is driven by a
    /// user-initiated navigation command.
    public static let automatic: DefaultFocusEvaluationPriority = .init(rawValue: 0)

    /// Always use the default focus preference when focus moves into the
    /// affected branch.
    public static let userInitiated: DefaultFocusEvaluationPriority = .init(rawValue: 1)
}
