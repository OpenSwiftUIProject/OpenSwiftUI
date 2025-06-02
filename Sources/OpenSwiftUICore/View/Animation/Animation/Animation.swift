package import OpenGraphShims

@frozen
public struct Animation: Equatable {
//    var box: AnimationBoxBase
    public static func == (lhs: Animation, rhs: Animation) -> Bool {
        // TODO
        true
    }

    public static var `default` = Animation()
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
    }

    package var description: String { "Animatable<\(Value.self)>" }

    package mutating func destroy() {
        // helper.animatorState?.removeListeners()
    }
}

// MARK: - AnimatableAttributeHelper [FIXME]

package struct AnimatableAttributeHelper<Value> where Value: Animatable {
    @Attribute var phase: _GraphInputs.Phase
    @Attribute var time: Time
    @Attribute var transaction: Transaction
    var previousModelData: Value.AnimatableData?
    // var animatorState: AnimatorState<Value.AnimatableData>?
    var resetSeed: UInt32 = 0

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
