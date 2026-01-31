//
//  EnvironmentWritingModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 327A94017466EC589024364A56314D10 (SwiftUI)

import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - Scene + environment

extension Scene {
    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func environment<K>(
        key: K.Type = K.self,
        value: K.Value
    ) -> some Scene where K: EnvironmentKey {
        modifier(EnvironmentWritingSceneModifier<K>(value: value))
    }
}

// MARK: - EnvironmentWritingModifier

private protocol EnvironmentWritingModifier: _GraphInputsModifier {
    associatedtype Key: EnvironmentKey

    var value: Key.Value { get }
}

// MARK: - EnvironmentWritingSceneModifier

struct EnvironmentWritingSceneModifier<Key>: PrimitiveSceneModifier, EnvironmentWritingModifier where Key: EnvironmentKey {
    var value: Key.Value

    static func _makeInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs
    ) {
        inputs.environment = Attribute(
            ChildEnvironment(
                modifier: modifier.value,
                environment: inputs.environment,
            )
        )
    }
}

// MARK: - ChildEnvironment

private struct ChildEnvironment<Modifier>: StatefulRule, AsyncAttribute, CustomStringConvertible where Modifier: EnvironmentWritingModifier {
    @Attribute var modifier: Modifier
    @Attribute var environment: EnvironmentValues
    var oldModifier: Modifier?

    init(
        modifier: Attribute<Modifier>,
        environment: Attribute<EnvironmentValues>,
        oldModifier: Modifier? = nil
    ) {
        self._modifier = modifier
        self._environment = environment
        self.oldModifier = oldModifier
    }

    var description: String {
        "EnvironmentWriting: \(Modifier.self)"
    }

    typealias Value = EnvironmentValues

    mutating func updateValue() {
        let (modifier, modifierChanged) = $modifier.changedValue()
        let (environment, environmentChanged) = $environment.changedValue()
        var modifierNeedsUpdate: Bool {
            guard modifierChanged else {
                return false
            }
            if let oldModifier {
                return compareValues(oldModifier.value, modifier.value)
            } else {
                return true
            }
        }
        if environmentChanged || !hasValue || modifierNeedsUpdate {
            var env = environment
            env[Modifier.Key.self] = modifier.value
            value = env
            oldModifier = modifier
        }
    }
}
