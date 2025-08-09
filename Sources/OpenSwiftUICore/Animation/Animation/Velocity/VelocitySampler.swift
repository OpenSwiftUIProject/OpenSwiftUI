//
//  VelocitySampler.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package struct VelocitySampler<T> where T: VectorArithmetic {
    private var sample1: (T, Time)?
    private var sample2: (T, Time)?
    private var sample3: (T, Time)?

    package private(set) var lastTime: Time?

    private let previousSampleWeight: Double

    package init() {
        sample1 = nil
        sample2 = nil
        sample3 = nil
        lastTime = nil
        previousSampleWeight = 0.75
    }

    package mutating func addSample(_ sample: T, time: Time) {
        if let lastTime, time < lastTime {
            Log.externalWarning(
                "Invalid sample \(sample) with time \(time) > last time \(lastTime)"
            )
            return
        }
        let newSample = (sample, time)
        if let lastTime, time - lastTime < .ulpOfOne {
            if sample3 != nil {
                sample3 = newSample
            } else if sample2 != nil {
                sample2 = newSample
            } else {
                sample1 = newSample
            }
        } else {
            lastTime = time
            if sample3 != nil {
                sample1 = sample2
                sample2 = sample3
                sample3 = newSample
            } else if sample2 != nil {
                sample3 = newSample
            } else if sample1 != nil {
                sample2 = newSample
            } else {
                sample1 = newSample
            }
        }
    }

    package mutating func reset() {
        self = .init()
    }

    package var isEmpty: Bool {
        // FIXME: The correct implmentation is lastTime == nil
        lastTime != nil
    }

    package var velocity: _Velocity<T> {
        guard let sample1, let sample2 else {
            return .zero
        }
        let velocity21 = _Velocity(valuePerSecond: (sample2.0 - sample1.0).scaled(by: 1.0 / (sample2.1 - sample1.1)))
        guard let sample3 else {
            return velocity21
        }
        let velocity32 = _Velocity(valuePerSecond: (sample3.0 - sample2.0).scaled(by: 1.0 / (sample3.1 - sample2.1)))
        return mix(velocity32, velocity21, by: previousSampleWeight)
    }
}

package struct AnimatableVelocitySampler<Value> where Value: Animatable {
    package var base: VelocitySampler<Value.AnimatableData>

    package init() {
        base = .init()
    }

    package init(base: VelocitySampler<Value.AnimatableData>) {
        self.base = base
    }

    package mutating func addSample(_ sample: Value, time: Time) {
        base.addSample(sample.animatableData, time: time)
    }

    package func velocity(_ value: Value) -> Value {
        var value = value
        value.animatableData = base.velocity.valuePerSecond
        return value
    }
}
