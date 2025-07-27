//
//  AnimationCompletion.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3BD3BDC4EA2CE1A6D6B152B168BCF9AD (SwiftUI)

/// Returns the result of recomputing the view's body with the provided
/// animation, and runs the completion when all animations are complete.
///
/// This function sets the given ``Animation`` as the ``Transaction/animation``
/// property of the thread's current ``Transaction`` as well as calling
/// ``Transaction/addAnimationCompletion`` with the specified completion.
///
/// The completion callback will always be fired exactly one time. If no
/// animations are created by the changes in `body`, then the callback will be
/// called immediately after `body`.
@available(OpenSwiftUI_v5_0, *)
public func withAnimation<Result>(
    _ animation: Animation? = .default,
    completionCriteria: AnimationCompletionCriteria = .logicallyComplete,
    _ body: () throws -> Result,
    completion: @escaping () -> Void
) rethrows -> Result {
    var transaction = Transaction()
    transaction.animation = animation
    transaction.addAnimationCompletion(criteria: completionCriteria, completion)
    return try withTransaction(transaction, body)
}

@available(OpenSwiftUI_v5_0, *)
extension Transaction {
    /// Adds a completion to run when the animations created with this
    /// transaction are all complete.
    ///
    /// The completion callback will always be fired exactly one time. If no
    /// animations are created by the changes in `body`, then the callback will
    /// be called immediately after `body`.
    public mutating func addAnimationCompletion(
        criteria: AnimationCompletionCriteria = .logicallyComplete,
        _ completion: @escaping () -> Void
    ) {
        if criteria == .logicallyComplete {
            addAnimationLogicalListener {
                Update.enqueueAction(reason: nil, completion)
            }
        } else {
            addAnimationListener {
                Update.enqueueAction(reason: nil, completion)
            }
        }
    }
}

/// The criteria that determines when an animation is considered finished.
@available(OpenSwiftUI_v5_0, *)
public struct AnimationCompletionCriteria: Hashable, Sendable {
    /// The animation has logically completed, but may still be in its long
    /// tail.
    ///
    /// If a subsequent change occurs that creates additional animations on
    /// properties with `logicallyComplete` completion callbacks registered,
    /// then those callbacks will fire when the animations from the change that
    /// they were registered with logically complete, ignoring the new
    /// animations.
    public static let logicallyComplete: AnimationCompletionCriteria = .init(storage: .logicallyComplete)

    /// The entire animation is finished and will now be removed.
    ///
    /// If a subsequent change occurs that creates additional animations on
    /// properties with `removed` completion callbacks registered, then those
    /// callbacks will only fire when *all* of the created animations are
    /// complete.
    public static let removed: AnimationCompletionCriteria = .init(storage: .removed)

    private enum Storage {
        case logicallyComplete
        case removed
    }

    private var storage: Storage
}
