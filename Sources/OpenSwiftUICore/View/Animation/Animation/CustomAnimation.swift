//
//  CustomAnimation.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: 35ADF281214A25133F1A6DF28858952D (SwiftUICore?)

package import Foundation
package import OpenGraphShims

// MARK: - FrameVelocityFilter [6.4.41]

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

    // private var animatorState: AnimatorState<Value.AnimatableData>?

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
