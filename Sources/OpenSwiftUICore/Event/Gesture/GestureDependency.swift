//
//  GestureDependency.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: 8687835E41FEE17B108D67665C1D2D0B (SwiftUICore)

import OpenGraphShims

// MARK: - GestureDependency [6.5.4]

package enum GestureDependency {
    case none
    case pausedWhileActive
    case pausedUntilFailed
    case failIfActive
}

extension Gesture {
    package func dependency(_ dependency: GestureDependency) -> some Gesture<Value> {
        modifier(DependentGesture(dependency: dependency))
    }
}

private struct DependentGesture<V>: GestureModifier {
    typealias Value = V

    typealias BodyValue = V

    var dependency: GestureDependency

    nonisolated static func _makeGesture(
        modifier: _GraphValue<Self>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<Value>
    ) -> _GestureOutputs<Value> {
        var outputs = body(inputs)
        outputs.phase = Attribute(DependentPhase(
            modifier: modifier.value,
            phase: outputs.phase,
            inheritedPhase: inputs.inheritedPhase
        ))
        if inputs.preferences.contains(GestureDependency.Key.self) {
            outputs.preferences[GestureDependency.Key.self] = modifier.value.dependency
        }
        return outputs
    }
}

extension GestureDependency {
    struct Key: PreferenceKey {
        static var defaultValue: GestureDependency { .none }

        static func reduce(value: inout GestureDependency, nextValue: () -> GestureDependency) {
            let nextValue = nextValue()
            let dict: [GestureDependency: Int] = [
                .none: 0,
                .pausedWhileActive: 1,
                .pausedUntilFailed: 2,
                .failIfActive: 3
            ]
            value = dict[value]! < dict[nextValue]! ? value : nextValue
        }
    }
}

private struct DependentPhase<V>: Rule {
    @Attribute var modifier: DependentGesture<V>
    @Attribute var phase: GesturePhase<V>
    @Attribute var inheritedPhase: _GestureInputs.InheritedPhase

    var value: GesturePhase<V> {
        phase.applyingDependency(modifier.dependency, inheritedPhase: inheritedPhase)
    }
}

extension GesturePhase {
    func paused() -> GesturePhase {
        switch self {
        case .possible, .failed: self
        case let .active(wrapped): .possible(wrapped)
        case let .ended(wrapped): .possible(wrapped)
        }
    }

    fileprivate func applyingDependency(_ dependency: GestureDependency, inheritedPhase: _GestureInputs.InheritedPhase) -> GesturePhase {
        switch dependency {
        case .none:
            self
        case .pausedWhileActive:
            if inheritedPhase.contains(.active) {
                paused()
            } else {
                self
            }
        case .pausedUntilFailed:
            if inheritedPhase.contains(.failed) {
                self
            } else {
                paused()
            }
        case .failIfActive:
            if inheritedPhase.contains(.active) {
                GesturePhase.failed
            } else if inheritedPhase.contains(.failed) {
                self
            } else {
                paused()
            }
        }
    }
}
