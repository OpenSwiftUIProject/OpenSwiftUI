//
//  AnimatableAttribute.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: 35ADF281214A25133F1A6DF28858952D (SwiftUICore)

package import Foundation
package import OpenGraphShims

// MARK: - AnimatableAttribute [6.4.41] [TODO]

package struct AnimatableAttribute<Value>: StatefulRule, AsyncAttribute, ObservedAttribute, CustomStringConvertible where Value: Animatable {
    @Attribute var source: Value
    @Attribute var environment: EnvironmentValues
    var helper: AnimatableAttributeHelper<Value>

    package init(
        source: Attribute<Value>,
        phase: Attribute<_GraphInputs.Phase>,
        time: Attribute<Time>,
        transaction: Attribute<Transaction>,
        environment: Attribute<EnvironmentValues>
    ) {
        _source = source
        _environment = environment
        helper = .init(phase: phase, time: time, transaction: transaction)
    }

    package mutating func updateValue() {
        // TODO
        // Blocked by helper
    }

    package var description: String { "Animatable<\(Value.self)>" }

    package mutating func destroy() {
        // helper.animatorState?.removeListeners()
    }
}

// MARK: - AnimatableFrameAttribute [6.4.41] [TODO]

package struct AnimatableFrameAttribute: StatefulRule, AsyncAttribute, ObservedAttribute {
    @Attribute
    private var position: ViewOrigin

    @Attribute
    private var size: ViewSize

    @Attribute
    private var pixelLength: CGFloat

    @Attribute
    private var environment: EnvironmentValues

    private var helper: AnimatableAttributeHelper<ViewFrame>

    let animationsDisabled: Bool

    package init(
        position: Attribute<ViewOrigin>,
        size: Attribute<ViewSize>,
        pixelLength: Attribute<CGFloat>,
        environment: Attribute<EnvironmentValues>,
        phase: Attribute<_GraphInputs.Phase>,
        time: Attribute<Time>,
        transaction: Attribute<Transaction>,
        animationsDisabled: Bool
    ) {
        _position = position
        _size = size
        _pixelLength = pixelLength
        _environment = environment
        helper = .init(phase: phase, time: time, transaction: transaction)
        self.animationsDisabled = animationsDisabled
    }

    package typealias Value = ViewFrame

    package mutating func updateValue() {
        let (position, positionChanged) = $position.changedValue()
        let (size, sizeChanged) = $size.changedValue()
        let (pixelLength, pixelLengthChanged) = $pixelLength.changedValue()
        let changed = positionChanged || sizeChanged || pixelLengthChanged
        var rect = CGRect(origin: position, size: size.value)
        rect.roundCoordinatesToNearestOrUp(toMultipleOf: pixelLength)
        let viewFrame = ViewFrame(
            origin: rect.origin,
            size: ViewSize(value: rect.size, proposal: size._proposal)
        )
        if !animationsDisabled {
            // TODO: helper
        }
        if changed || !hasValue {
            value = viewFrame
        }
    }

    package mutating func destroy() {
        // helper.animatorState?.removeListeners()
    }
}

// MARK: - AnimatableFrameAttributeVFD [6.4.41] [TODO]

package struct AnimatableFrameAttributeVFD: StatefulRule, AsyncAttribute, ObservedAttribute {
    @Attribute
    private var position: ViewOrigin

    @Attribute
    private var size: ViewSize

    @Attribute
    private var pixelLength: CGFloat

    @Attribute
    private var environment: EnvironmentValues

    private var helper: AnimatableAttributeHelper<ViewFrame>

    private var velocityFilter: FrameVelocityFilter

    let animationsDisabled: Bool

    package init(
        position: Attribute<ViewOrigin>,
        size: Attribute<ViewSize>,
        pixelLength: Attribute<CGFloat>,
        environment: Attribute<EnvironmentValues>,
        phase: Attribute<_GraphInputs.Phase>,
        time: Attribute<Time>,
        transaction: Attribute<Transaction>,
        animationsDisabled: Bool
    ) {
        _position = position
        _size = size
        _pixelLength = pixelLength
        _environment = environment
        helper = .init(phase: phase, time: time, transaction: transaction)
        velocityFilter = FrameVelocityFilter()
        self.animationsDisabled = animationsDisabled
    }

    package typealias Value = ViewFrame

    package mutating func updateValue() {
        let (position, positionChanged) = $position.changedValue()
        let (size, sizeChanged) = $size.changedValue()
        let (pixelLength, pixelLengthChanged) = $pixelLength.changedValue()
        let changed = positionChanged || sizeChanged || pixelLengthChanged
        var rect = CGRect(origin: position, size: size.value)
        rect.roundCoordinatesToNearestOrUp(toMultipleOf: pixelLength)
        let viewFrame = ViewFrame(
            origin: rect.origin,
            size: ViewSize(value: rect.size, proposal: size._proposal)
        )
        if !animationsDisabled {
            // TODO
        }
        if changed || !hasValue {
            value = viewFrame
        }
    }

    package mutating func destroy() {
        // helper.animatorState?.removeListeners()
    }
}

// MARK: - AnimatableAttributeHelper [FIXME]

package struct AnimatableAttributeHelper<Value> where Value: Animatable {
    @Attribute
    private var phase: _GraphInputs.Phase

    @Attribute
    private var time: Time

    @Attribute
    private var transaction: Transaction

    private var previousModelData: Value.AnimatableData?

    private var animatorState: AnimatorState<Value.AnimatableData>?

    private var resetSeed: UInt32 = 0

    init(
        phase: Attribute<_GraphInputs.Phase>,
        time: Attribute<Time>,
        transaction: Attribute<Transaction>
    ) {
        _phase = phase
        _time = time
        _transaction = transaction
    }
}

// MARK: - AnimatorState

final package class AnimatorState<V> where V: VectorArithmetic {
    private var animation: Animation

    private var state: AnimationState<V> = .init()

    private var interval: V = .zero

    private var beginTime: Time

    private var quantizedFrameInterval: Double

    private var nextTime: Time = .zero

    private var previousAnimationValue: V = .zero

    private var reason: UInt32? = nil

    private enum Phase {
        case pending
        case first
        case second
        case running
    }

    private var phase: Phase = .pending

    private var listeners: [AnimationListener] = []

    private var logicalListeners: [AnimationListener] = []

    private var isLogicallyComplete: Bool = false

    private struct Fork {
        var animation: Animation
        var state: AnimationState<V>
        var interval: V
        var listeners: [AnimationListener]

        func update(time: Double, environment: Attribute<EnvironmentValues>?) -> Bool {
            var context = AnimationContext(state: state, environment: environment, isLogicallyComplete: false)
            let animtedValue = animation.animate(value: interval, time: time, context: &context)
            return animtedValue == nil || context.isLogicallyComplete
        }
    }

    private var forks: [Fork] = []

    init(
        animation: Animation,
        interval: V,
        at time: Time,
        in transaction: Transaction
    ) {
        self.animation = animation
        self.interval = interval
        self.beginTime = time
        self.nextTime = time
        if let animationFrameInterval = transaction.animationFrameInterval {
            self.quantizedFrameInterval = if animationFrameInterval <= .zero {
                .zero
            } else {
                exp2(floor(log2(animationFrameInterval * 240.0) + 0.01)) / 240.0
            }
            if quantizedFrameInterval < 1.0 / 60.0 {
                self.reason = transaction.animationReason
            } else {
                self.reason = nil
            }
        } else {
            self.quantizedFrameInterval = .zero
            self.reason = nil
        }
    }

    package func updateListeners(
        isLogicallyComplete: Bool,
        time: TimeInterval,
        environment: Attribute<EnvironmentValues>?
    ) {
        if !self.isLogicallyComplete, isLogicallyComplete {
            self.isLogicallyComplete = true
            logicalListeners.forEach { $0.animationWasRemoved() }
            logicalListeners = []
        }
        if !forks.isEmpty {
            var set = IndexSet()
            for index in forks.indices {
                guard forks[index].update(time: time, environment: environment) else {
                    continue
                }
                forks[index].listeners.forEach { $0.animationWasRemoved() }
                set.insert(index)
            }
            forks.remove(atOffsets: set)
        }
    }

    package func removeListeners() {
        listeners.forEach { $0.animationWasRemoved() }
        listeners = []
        listeners.forEach { $0.animationWasRemoved() }
        logicalListeners = []
    }

    package func forkListeners(
        animation: Animation,
        state: AnimationState<V>,
        interval: V
    ) {
        guard !isLogicallyComplete, !logicalListeners.isEmpty else {
            return
        }
        let fork = Fork(
            animation: animation,
            state: state,
            interval: interval,
            listeners: logicalListeners
        )
        forks.append(fork)
    }

    package func combine(
        newAnimation: Animation,
        newInterval: V,
        at time: Time,
        in transaction: Transaction,
        environment: Attribute<EnvironmentValues>?
    ) {
        if phase == .pending, !Semantics.MergeCoincidentAnimations.isEnabled {
            animation = newAnimation
            interval = newInterval
        } else {
            let elapsed = time - beginTime
            var context = AnimationContext(
                state: state,
                environment: environment,
                isLogicallyComplete: isLogicallyComplete
            )
            forkListeners(animation: animation, state: state, interval: interval)
            isLogicallyComplete = false
            if newAnimation.shouldMerge(
                previous: animation,
                value: interval,
                time: elapsed,
                context: &context
            ) {
                state = context.state
                animation = newAnimation
            } else {
                combineAnimation(
                    into: &animation,
                    state: &state,
                    value: interval,
                    elapsed: elapsed,
                    newAnimation: newAnimation,
                    newValue: newInterval
                )
            }
            interval += newInterval
            nextTime = time
        }
        if let animationFrameInterval = transaction.animationFrameInterval {
            let newQuantizedFrameInterval: Double = if animationFrameInterval <= .zero {
                .zero
            } else {
                exp2(floor(log2(animationFrameInterval * 240.0) + 0.01)) / 240.0
            }
            quantizedFrameInterval = min(
                newQuantizedFrameInterval,
                quantizedFrameInterval
            )
            if quantizedFrameInterval < 1.0 / 60.0 {
                self.reason = transaction.animationReason
            } else {
                self.reason = nil
            }
        }
    }

    package func update(
        _ value: inout V,
        at time: Time,
        environment: Attribute<EnvironmentValues>?
    ) -> Bool {
        guard time > nextTime + quantizedFrameInterval * -0.5 else {
            value += previousAnimationValue
            value -= interval
            return false
        }
        switch phase {
        case .pending:
            beginTime = time
            phase = .first
        case .first:
            phase = .second
            guard CoreGlue.shared.hasTestHost() else {
                nextTime += time - beginTime
                beginTime = time
                value += previousAnimationValue
                value -= interval
                return false
            }
        case .second:
            let doubleInterval = max(quantizedFrameInterval, 1.0 / 60.0) + quantizedFrameInterval
            if doubleInterval < time - beginTime {
                if !CoreGlue.shared.hasTestHost() {
                    beginTime = time - doubleInterval
                }
            }
            phase = .running
        case .running:
            break
        }
        let elapsed = time - beginTime
        var context = AnimationContext(
            state: state,
            environment: environment,
            isLogicallyComplete: isLogicallyComplete
        )
        guard let newValue = animation.animate(
            value: interval,
            time: elapsed,
            context: &context
        ) else {
            return true
        }
        updateListeners(
            isLogicallyComplete: context.isLogicallyComplete,
            time: elapsed,
            environment: environment
        )
        value += newValue
        value -= interval
        previousAnimationValue = newValue
        nextTime = time
        if quantizedFrameInterval > .zero {
            nextTime = Time(seconds: (floor(time.seconds / quantizedFrameInterval) + 1.0) * quantizedFrameInterval)
        }
        return false
    }

    package func nextUpdate() {
        CoreGlue.shared.nextUpdate(
            nextTime: nextTime,
            interval: quantizedFrameInterval,
            reason: reason
        )
    }

    package func addListeners(transaction: Transaction) {
        if let listener = transaction.animationListener {
            listeners.append(listener)
            listener.animationWasAdded()
        }
        if let logicalListener = transaction.animationLogicalListener {
            logicalListener.animationWasAdded()
            if isLogicallyComplete {
                logicalListener.animationWasRemoved()
            } else {
                logicalListeners.append(logicalListener)
            }
        }
    }
}

// MARK: - FrameVelocityFilter

private struct FrameVelocityFilter {
    var currentVelocity: Double?
    var previous: ((Time, CGRect.AnimatableData))?

    mutating func addSample(_ rect: CGRect.AnimatableData, time: Time) {
        guard let (previousTime, previousRect) = previous,
              previousTime <= time else {
            previous = (time, rect)
            return
        }
        let deltaX = rect.first.first - previousRect.first.first
        let deltaY = rect.first.second - previousRect.first.second
        let deltaWidth = rect.second.first - previousRect.second.first
        let deltaHeight = rect.second.second - previousRect.second.second

        let timeFactor = 1.0 / (time - previousTime)

        let velocityX = timeFactor * deltaX
        let velocityY = timeFactor * deltaY
        let velocityWidth = timeFactor * deltaWidth
        let velocityHeight = timeFactor * deltaHeight

        let velocityRect = CGRect(x: velocityX, y: velocityY, width: velocityWidth, height: velocityHeight)
        let newVelocity = max(abs(velocityRect.minX), abs(velocityRect.maxX), abs(velocityRect.minY), abs(velocityRect.maxY))
        if let existingVelocity = currentVelocity {
            currentVelocity = mix(existingVelocity, newVelocity, by: 0.35)
        } else {
            currentVelocity = newVelocity
        }
        previous = (time, rect)
    }
}

// FIXME
func combineAnimation<A>(
    into: inout Animation,
    state: inout AnimationState<A>,
    value: A,
    elapsed: Double,
    newAnimation: Animation,
    newValue: A
) -> () where A: VectorArithmetic {
    _openSwiftUIUnimplementedFailure()
}
