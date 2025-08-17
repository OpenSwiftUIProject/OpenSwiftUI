//
//  VelocityTrackingAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: FD9125BC1E04E33D1D7BE4A31225AA98 (SwiftUICore)

import Foundation

// MARK: - TracksVelocityKey

private struct TracksVelocityKey: TransactionKey {
    static var defaultValue: Bool { false }
}

@available(OpenSwiftUI_v5_0, *)
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
    static let velocityTracking: Animation = Animation(VelocityTrackingAnimation())
}

private struct VelocityTrackingAnimation: CustomAnimation {
    nonisolated func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V : VectorArithmetic {
        var sampler = context.velocityState.sampler
        if sampler.isEmpty { // FIXME: Verify this logic
            sampler.addSample(value, time: .init(seconds: time))
            context.velocityState = .init(sampler: sampler)
        }
        let newTime = (sampler.lastTime?.seconds ?? .zero) + 2.0
        let velocity = velocity(
            value: value,
            time: time,
            context: context
        )
        if let velocity, velocity == .zero {
            return nil
        }
        guard newTime > time else {
            return nil
        }
        return value
    }


    nonisolated func velocity<V>(
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V : VectorArithmetic {
        let timeDiff = time - (context.velocityState.sampler.lastTime?.seconds ?? .zero)
        let scale = pow(0.998, timeDiff * 1000)
        return context.velocityState.sampler.velocity.scaled(by: scale).valuePerSecond
    }

    nonisolated func shouldMerge<V>(
        previous: Animation,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic {
        context.velocityState.sampler.addSample(value, time: .init(seconds: time))
        return true
    }
}

extension AnimationContext {
    fileprivate var velocityState: VelocityState<Value> {
        get { state[VelocityState<Value>.self] }
        set { state[VelocityState<Value>.self] = newValue }
    }
}

private struct VelocityState<Value>: AnimationStateKey where Value: VectorArithmetic {
    static var defaultValue: VelocityState {
        VelocityState(sampler: .init())
    }

    var sampler: VelocitySampler<Value>
}
