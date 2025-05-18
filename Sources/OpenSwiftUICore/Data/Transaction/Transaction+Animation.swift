//
//  Transaction+Animation.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete
//  ID: 39EC6D46662E6D7A6963F5C611934B0A

private struct AnimationKey: TransactionKey {
    static let defaultValue: Animation? = nil
}

private struct DisablesAnimationsKey: TransactionKey {
    static var defaultValue: Bool { false }
}

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
    
    /// A Boolean value that indicates whether views should disable animations.
    ///
    /// This value is `true` during the initial phase of a two-part transition
    /// update, to prevent ``View/animation(_:)`` from inserting new animations
    /// into the transaction.
    public var disablesAnimations: Bool {
        get { self[DisablesAnimationsKey.self] }
        set { self[DisablesAnimationsKey.self] = newValue }
    }
}
