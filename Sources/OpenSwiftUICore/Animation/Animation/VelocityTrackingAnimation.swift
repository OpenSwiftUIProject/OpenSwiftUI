//
//  VelocityTrackingAnimation.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: FD9125BC1E04E33D1D7BE4A31225AA98 (SwiftUICore)

// MARK: - TracksVelocityKey

private struct TracksVelocityKey: TransactionKey {
    static var defaultValue: Bool { false }
}

extension Transaction {
    /// Whether this transaction will track the velocity of any animatable
    /// properties that change.
    ///
    /// This property can be enabled in an interactive context to track velocity
    /// during a user interaction so that when the interaction ends, an
    /// animation can use the accumulated velocities to create animations that
    /// preserve them. This tracking is mutually exclusive with an animation
    /// being used during a view change, since if there is an animation, it is
    /// responsible for managing its own velocity.
    ///
    /// Gesture onChanged and updating callbacks automatically set this property
    /// to true.
    ///
    /// This example shows an interaction which applies changes, tracking
    /// velocity until the final change, which applies an animation (which will
    /// start with the velocity that was tracked during the previous changes).
    /// These changes could come from a server or from an interactive control
    /// like a slider.
    ///
    ///     func receiveChange(change: ChangeInfo) {
    ///         var transaction = Transaction()
    ///         if change.isFinal {
    ///             transaction.animation = .spring
    ///         } else {
    ///             transaction.tracksVelocity = true
    ///         }
    ///         withTransaction(transaction) {
    ///             state.applyChange(change)
    ///         }
    ///     }
    public var tracksVelocity: Bool {
        get { self[TracksVelocityKey.self] }
        set { self[TracksVelocityKey.self] = newValue }
    }
}

extension Animation {
    // FIXME: VelocityTrackingAnimation
    static let velocityTracking: Animation = Animation()
}
