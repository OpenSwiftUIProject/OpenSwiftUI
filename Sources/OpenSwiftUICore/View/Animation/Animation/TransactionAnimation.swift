//
//  TransactionAnimation.swift
//  OpenSwiftUICore
//
//  Audited for iOS 6.0.87
//  Status: Complete
//  ID: 39EC6D46662E6D7A6963F5C611934B0A (SwiftUI)
//  ID: D98E9A1069CEEADA58829ED440E36F30 (SwiftUICore)

extension Transaction {
    /// Creates a transaction and assigns its animation property.
    ///
    /// - Parameter animation: The animation to perform when the current state
    ///   changes.
    public init(animation: Animation?) {
        self.init()
        self.animation = animation
    }
    
    /// The animation, if any, associated with the current state change.
    public var animation: Animation? {
        get { self[AnimationKey.self] }
        set { self[AnimationKey.self] = newValue }
    }

    package var effectiveAnimation: Animation? {
        animation ?? (tracksVelocity ? .velocityTracking : nil)
    }

    package var _animationFrameInterval: Double? {
        get { self[AnimationFrameIntervalKey.self] }
        set { self[AnimationFrameIntervalKey.self] = newValue }
    }

    package var animationFrameInterval: Double? {
        get { _animationFrameInterval }
        set { _animationFrameInterval = newValue }
    }

    package var _animationReason: UInt32? {
        get { self[AnimationReasonKey.self] }
        set { self[AnimationReasonKey.self] = newValue }
    }

    package var animationReason: UInt32? {
        get { _animationReason }
        set { _animationReason = newValue }
    }

    package var isAnimated: Bool {
        guard animation != nil,
              !disablesAnimations else {
            return false
        }
        return true
    }

    /// A Boolean value that indicates whether views should disable animations.
    ///
    /// This value is `true` during the initial phase of a two-part transition
    /// update, to prevent ``View/animation(_:)`` from inserting new animations
    /// into the transaction.
    public var disablesAnimations: Bool {
        get { self[DisablesAnimationsKey.self] }
        set { self[DisablesAnimationsKey.self] = newValue }
    }

    package var disablesContentTransitions: Bool {
        get { self[DisablesContentTransactionKey.self] }
        set { self[DisablesContentTransactionKey.self] = newValue }
      }

    package mutating func disableAnimations() {
        animation = nil
        disablesAnimations = true
    }

    package var animationIgnoringTransitionPhase: Animation? {
        guard disablesAnimations else {
            return animation
        }
        var result: Animation?
        forEach(keyType: AnimationKey.self) { animation, stop in
            guard let animation else {
                return
            }
            result = animation
            stop = true
        }
        return result
    }
}

private struct AnimationKey: TransactionKey {
    static var defaultValue: Animation? { nil }
}

private struct DisablesAnimationsKey: TransactionKey {
    static var defaultValue: Bool { false }
}

private struct AnimationFrameIntervalKey: TransactionKey {
    static var defaultValue: Double? { nil }
}

private struct AnimationReasonKey: TransactionKey {
    static var defaultValue: UInt32? { nil }
}

private struct DisablesContentTransactionKey: TransactionKey {
    static var defaultValue: Bool { false }
}
