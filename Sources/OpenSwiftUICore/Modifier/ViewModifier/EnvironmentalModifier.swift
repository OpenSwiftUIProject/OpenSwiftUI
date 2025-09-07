//
//  EnvironmentalModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A1B6966B83442495FADFE75F475ECBE2 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - EnvironmentalModifier

/// A modifier that must resolve to a concrete modifier in an environment before
/// use.
@available(OpenSwiftUI_v1_0, *)
public protocol EnvironmentalModifier: ViewModifier where Body == Never {
    /// The type of modifier to use after being resolved.
    associatedtype ResolvedModifier: ViewModifier
    
    /// Resolve to a concrete modifier in the given `environment`.
    func resolve(in environment: EnvironmentValues) -> ResolvedModifier
    
    @available(OpenSwiftUI_v3_0, *)
    static var _requiresMainThread: Bool { get }
    
    @available(OpenSwiftUI_v5_0, *)
    static var _tracksEnvironmentDependencies: Bool { get }
}

// MARK: - EnvironmentalModifier Default Implementations

@available(OpenSwiftUI_v1_0, *)
extension EnvironmentalModifier {
    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        let fields = DynamicPropertyCache.fields(of: Self.self)
        let (resolvedModifier, buffer) = makeResolvedModifier(modifier: modifier, inputs: &inputs.base, fields: fields)
        let outputs = ResolvedModifier.makeDebuggableView(
            modifier: resolvedModifier,
            inputs: inputs,
            body: body
        )
        if let buffer {
            buffer.traceMountedProperties(to: modifier, fields: fields)
        }
        return outputs
    }
    
    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        let fields = DynamicPropertyCache.fields(of: Self.self)
        let (resolvedModifier, buffer) = makeResolvedModifier(modifier: modifier, inputs: &inputs.base, fields: fields)
        let outputs = ResolvedModifier.makeDebuggableViewList(
            modifier: resolvedModifier,
            inputs: inputs,
            body: body
        )
        if let buffer {
            buffer.traceMountedProperties(to: modifier, fields: fields)
        }
        return outputs
    }

    nonisolated private static func makeResolvedModifier(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<ResolvedModifier>, _DynamicPropertyBuffer?) {
        guard Metadata(Self.self).isValueType else {
            preconditionFailure("Environmental modifiers must be value types: \(Self.self)")
        }
        var fields = fields
        if !fields.behaviors.contains(.requiresMainThread), !_requiresMainThread {
            fields.behaviors.formUnion(
                !fields.behaviors.contains(.allowsAsync) && isLinkedOnOrAfter(.v4) ? .allowsAsync : []
            )
        }
        let accessor = EnvironmentalBodyAccessor<Self>(
            environment: inputs.environment,
            tracksDependencies: _tracksEnvironmentDependencies
        )
        return accessor.makeBody(container: modifier, inputs: &inputs, fields: fields)
    }

    @available(OpenSwiftUI_v3_0, *)
    public static var _requiresMainThread: Bool {
        true
    }

    @available(OpenSwiftUI_v5_0, *)
    public static var _tracksEnvironmentDependencies: Bool {
        true
    }
}

// MARK: - EnvironmentalBodyAccessor

private struct EnvironmentalBodyAccessor<V>: BodyAccessor where V: EnvironmentalModifier {
    typealias Container = V

    typealias Body = V.ResolvedModifier

    @Attribute
    var environment: EnvironmentValues
    let tracker: PropertyList.Tracker
    let tracksDependencies: Bool

    init(
        environment: Attribute<EnvironmentValues>,
        tracksDependencies: Bool
    ) {
        self._environment = environment
        self.tracker = .init()
        self.tracksDependencies = tracksDependencies
    }

    func updateBody(of container: V, changed: Bool) {
        let (environment, environmentChanged) = $environment.changedValue()
        guard changed ||
            (
                environmentChanged && (
                    !tracksDependencies ||
                    tracker.hasDifferentUsedValues(environment.plist)
                )
            )
        else {
            return
        }
        tracker.reset()
        let newEnvironment = EnvironmentValues(environment.plist, tracker: tracker)
        setBody {
            container.resolve(in: newEnvironment)
        }
    }
}
