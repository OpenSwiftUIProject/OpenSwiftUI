//
//  DefaultCombiningAnimation.swift
//  OpenSwiftUICore
//
//  Audited: 6.5.4
//  Status: Complete
//  ID: 0E899C244938BDADF95265D65460D266 (SwiftUICore)

import Foundation

@_specialize(exported: false, kind: partial, where V == Double)
@_specialize(exported: false, kind: partial, where V == AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>)
func combineAnimation<V>(
    into animation: inout Animation,
    state: inout AnimationState<V>,
    value: V,
    elapsed: Double,
    newAnimation: Animation,
    newValue: V
) where V: VectorArithmetic {
    if var defaultCombiningAnimation = animation.as(DefaultCombiningAnimation.self) {
        state.combinedState.entries.append(.init(value: value + newValue, state: .init()))
        defaultCombiningAnimation.entries.append(.init(animation: newAnimation, elapsed: elapsed))
        animation = Animation(defaultCombiningAnimation)
    } else {
        var s = AnimationState<V>()
        s.combinedState.entries.append(.init(value: value, state: state))
        s.combinedState.entries.append(.init(value: value + newValue, state: .init()))
        state = s
        animation = Animation(DefaultCombiningAnimation(entries: [
            .init(animation: animation, elapsed: .zero),
            .init(animation: newAnimation, elapsed: elapsed)
        ]))
    }
}

extension AnimationState {
    fileprivate var combinedState: CombinedAnimationState<Value> {
        get { self[CombinedAnimationState<Value>.self] }
        set { self[CombinedAnimationState<Value>.self] = newValue }
    }
}

struct CombinedAnimationState<Value>: AnimationStateKey where Value: VectorArithmetic {
    static var defaultValue: Self {
        .init(entries: [])
    }

    struct Entry {
        var value: Value
        var state: AnimationState<Value>?
    }

    var entries: [Entry]
}

private struct DefaultCombiningAnimation: CustomAnimation {
    struct Entry: Hashable {
        var animation: Animation
        var elapsed: Double
    }

    var entries: [Entry]

    @_specialize(exported: false, kind: partial, where V == Double)
    @_specialize(exported: false, kind: partial, where V == AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>)
    nonisolated func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        let combinedStateEntryCount = context.state.combinedState.entries.count
        guard combinedStateEntryCount == entries.count else {
            return nil
        }
        var result: V = .zero
        for index in 0 ..< combinedStateEntryCount {
            let entry = entries[index]
            guard let combinedStateEntryState = context.state.combinedState.entries[index].state else {
                result = context.state.combinedState.entries[index].value
                continue
            }
            var entryContext = context
            entryContext.state = combinedStateEntryState
            var entryValue = context.state.combinedState.entries[index].value
            entryValue -= result
            let elapsed = time - entry.elapsed
            let entryAnimatedValue = entry.animation.animate(
                value: entryValue,
                time: elapsed,
                context: &entryContext
            )
            if let entryAnimatedValue {
                context.state.combinedState.entries[index].state = entryContext.state
                result += entryAnimatedValue
            } else {
                context.state.combinedState.entries[index].state = nil
                result += entryValue
            }
            if index == combinedStateEntryCount - 1 {
                context.isLogicallyComplete = entryContext.isLogicallyComplete
                if entryAnimatedValue == nil {
                    return nil
                } else {
                    return result
                }
            }
        }
        return nil
    }
}
