//
//  Transaction+isContinuous.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete
//  ID: 73F9B1285B58E062EB66BE983530A970

private struct ContinuousKey: TransactionKey {
    static var defaultValue: Bool { false }
}

extension Transaction {
    /// A Boolean value that indicates whether the transaction originated from
    /// an action that produces a sequence of values.
    ///
    /// This value is `true` if a continuous action created the transaction, and
    /// is `false` otherwise. Continuous actions include things like dragging a
    /// slider or pressing and holding a stepper, as opposed to tapping a
    /// button.
    public var isContinuous: Bool {
        get { plist[Key<ContinuousKey>.self] }
        set { plist[Key<ContinuousKey>.self] = newValue }
    }
}
