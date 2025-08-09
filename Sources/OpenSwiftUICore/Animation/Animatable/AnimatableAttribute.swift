//
//  AnimatableAttribute.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by Trace
//  ID: 35ADF281214A25133F1A6DF28858952D (SwiftUICore)

package import Foundation
package import OpenGraphShims

// MARK: - AnimatableAttribute

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
        var sourceValue = $source.changedValue()
        helper.update(
            value: &sourceValue,
            defaultAnimation: nil,
            environment: $environment
        )
        guard sourceValue.changed || !hasValue else {
            return
        }
        value = sourceValue.value
    }

    package var description: String { "Animatable<\(Value.self)>" }

    package mutating func destroy() {
        helper.removeListeners()
    }
}

// MARK: - AnimatableFrameAttribute

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
        let anyChanged = positionChanged || sizeChanged || pixelLengthChanged
        var rect = CGRect(origin: position, size: size.value)
        rect.roundCoordinatesToNearestOrUp(toMultipleOf: pixelLength)
        let viewFrame = ViewFrame(
            origin: rect.origin,
            size: ViewSize(value: rect.size, proposal: size._proposal)
        )
        var sourceValue = (
            value: viewFrame,
            changed: anyChanged
        )
        if !animationsDisabled {
            helper.update(
                value: &sourceValue,
                defaultAnimation: nil,
                environment: $environment
            )
        }
        guard sourceValue.changed || !hasValue else {
            return
        }
        value = sourceValue.value
    }

    package mutating func destroy() {
        helper.removeListeners()
    }
}

// MARK: - AnimatableFrameAttributeVFD

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
        let anyChanged = positionChanged || sizeChanged || pixelLengthChanged
        var rect = CGRect(origin: position, size: size.value)
        rect.roundCoordinatesToNearestOrUp(toMultipleOf: pixelLength)
        let viewFrame = ViewFrame(
            origin: rect.origin,
            size: ViewSize(value: rect.size, proposal: size._proposal)
        )
        var sourceValue = (
            value: viewFrame,
            changed: anyChanged
        )
        if !animationsDisabled {
            helper.update(
                value: &sourceValue,
                defaultAnimation: nil,
                environment: $environment
            )
        }
        guard sourceValue.changed || !hasValue else {
            return
        }
        value = sourceValue.value
    }

    package mutating func destroy() {
        helper.removeListeners()
    }
}

// MARK: - AnimatableAttributeHelper

package struct AnimatableAttributeHelper<Value> where Value: Animatable {
    @Attribute
    package var phase: _GraphInputs.Phase

    @Attribute
    package var time: Time

    @Attribute
    package var transaction: Transaction

    private var previousModelData: Value.AnimatableData? = nil

    private var animatorState: AnimatorState<Value.AnimatableData>? = nil

    private var resetSeed: UInt32 = 0

    package init(
        phase: Attribute<_GraphInputs.Phase>,
        time: Attribute<Time>,
        transaction: Attribute<Transaction>
    ) {
        _phase = phase
        _time = time
        _transaction = transaction
    }

    package var isAnimating: Bool {
        animatorState != nil
    }

    @inline(__always)
    private mutating func updateAnimatorStateIfNeeded(
        value: (value: Value, changed: Bool),
        animationTime: inout Time,
        environment: Attribute<EnvironmentValues>,
        sampleCollector: (Value.AnimatableData, Time) -> Void
    ) {
        guard value.changed else {
            return
        }
        let modelData = value.value.animatableData
        defer { previousModelData = modelData }
        guard let previousModelData, modelData != previousModelData else {
            return
        }
        let transaction: Transaction = Graph.withoutUpdate { self.transaction }
        guard let animation = transaction.effectiveAnimation else {
            return
        }
        var interval = modelData
        interval -= previousModelData
        animationTime = time

        let state: AnimatorState<Value.AnimatableData>
        if let animatorState {
            state = animatorState
            animatorState.combine(
                newAnimation: animation,
                newInterval: interval,
                at: animationTime,
                in: transaction,
                environment: environment
            )
            // TODO: CustomEventTrace
        } else {
            state = AnimatorState(
                animation: animation,
                interval: interval,
                at: animationTime,
                in: transaction
            )
            // TODO: CustomEventTrace
            animatorState = state
        }
        state.addListeners(transaction: transaction)
    }

    @inline(__always)
    private mutating func updateValueIfNeeded(
        value: inout (value: Value, changed: Bool),
        animationTime: Time,
        environment: Attribute<EnvironmentValues>,
        sampleCollector: (Value.AnimatableData, Time) -> Void
    ) {
        guard let animatorState else {
            return
        }
        var animatableData = value.value.animatableData
        let isAnimationOver = animatorState.update(
            &animatableData,
            at: animationTime,
            environment: environment
        )
        // let attribute = AnyAttribute.current // For tracing
        if isAnimationOver {
            // TODO: [Trace] CustomEventTrace + OGGraphAddTraceEvent
            // TODO: Signpost
            removeListeners()
            self.animatorState = nil
        } else {
            // TODO: [Trace] CustomEventTrace + OGGraphAddTraceEvent
            sampleCollector(animatableData, time)
            animatorState.nextUpdate()
        }
        value.value.animatableData = animatableData
        value.changed = true
    }

    package mutating func update(
        value: inout (value: Value, changed: Bool),
        defaultAnimation: Animation?,
        environment: Attribute<EnvironmentValues>,
        sampleCollector: (Value.AnimatableData, Time) -> Void
    ) {
        var animationTime = -Time.infinity
        if animatorState != nil {
            let (time, timeChanged) = $time.changedValue()
            if timeChanged {
                animationTime = time
            }
        }
        let reseted = checkReset()
        if reseted {
            value.changed = true
        }
        updateAnimatorStateIfNeeded(
            value: value,
            animationTime: &animationTime,
            environment: environment,
            sampleCollector: sampleCollector
        )
        updateValueIfNeeded(
            value: &value,
            animationTime: animationTime,
            environment: environment,
            sampleCollector: sampleCollector
        )
    }

    package mutating func update(
        value: inout (value: Value, changed: Bool),
        defaultAnimation: Animation?,
        environment: Attribute<EnvironmentValues>
    ) {
        update(
            value: &value,
            defaultAnimation: defaultAnimation,
            environment: environment
        ) { _, _ in
            _openSwiftUIEmptyStub()
        }
    }

    package mutating func checkReset() -> Bool {
        guard phase.resetSeed != resetSeed else {
            return false
        }
        reset()
        return true
    }

    package mutating func reset() {
        removeListeners()
        animatorState = nil
        previousModelData = nil
        resetSeed = phase.resetSeed
    }

    package mutating func removeListeners() {
        animatorState?.removeListeners()
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
        state = context.state
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
