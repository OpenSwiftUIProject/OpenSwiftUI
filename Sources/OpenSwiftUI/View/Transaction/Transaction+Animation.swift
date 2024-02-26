//
//  Transaction+Animation.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
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
        self.plist = PropertyList()
        self.animation = animation
    }
    
    /// The animation, if any, associated with the current state change.
    public var animation: Animation? {
        get { plist[Key<AnimationKey>.self] }
        set { plist[Key<AnimationKey>.self] = newValue }
    }
    
    /// A Boolean value that indicates whether views should disable animations.
    ///
    /// This value is `true` during the initial phase of a two-part transition
    /// update, to prevent ``View/animation(_:)`` from inserting new animations
    /// into the transaction.
    public var disablesAnimations: Bool {
        get { plist[Key<DisablesAnimationsKey>.self] }
        set { plist[Key<DisablesAnimationsKey>.self] = newValue }
    }
}
