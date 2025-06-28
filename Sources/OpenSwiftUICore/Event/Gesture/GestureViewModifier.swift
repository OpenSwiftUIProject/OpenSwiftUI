//
//  GestureViewModifier.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: 9DF46B4E935FF03A55FF3DDFB0B1FF2B (SwiftUICore)

package import OpenGraphShims

// MARK: - GestureViewModifier [6.5.4]

package protocol GestureViewModifier: MultiViewModifier, PrimitiveViewModifier {
    associatedtype ContentGesture: Gesture
    
    associatedtype Combiner: GestureCombiner = DefaultGestureCombiner
    
    var gesture: Self.ContentGesture { get }
    
    var name: String? { get }
    
    var gestureMask: GestureMask { get }
}

// MARK: - GestureResponderExclusionPolicy [6.5.4]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public enum GestureResponderExclusionPolicy {
    case `default`
    
    case highPriority
    
    case simultaneous
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension GestureResponderExclusionPolicy: Sendable {}

// MARK: - GestureCombiner [6.5.4]

package protocol GestureCombiner {
    associatedtype Result: Gesture /*where Result.Value == ()*/

    static func combine(
        _ gesture1: AnyGesture<Void>,
        _ gesture2: AnyGesture<Void>
    ) -> Self.Result
    
    static var exclusionPolicy: GestureResponderExclusionPolicy { get }
}

// MARK: - GestureViewModifier + Default Implementation [6.5.4]

extension GestureViewModifier {
    package var name: String? { nil }
    
    package var gestureMask: GestureMask { .all }
    
    package static func makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.preferences.requiresViewResponders {
            let filter = GestureFilter(
                children: outputs.viewResponders(),
                modifier: modifier.value,
                inputs: inputs,
                viewSubgraph: .current!
            )
            outputs.preferences.viewResponders = Attribute(filter)
        }
        let provider = inputs.gestureAccessibilityProvider
        provider.makeGesture(
            mask: modifier.value[keyPath: \.gestureMask],
            inputs: inputs,
            outputs: &outputs
        )
        return outputs
    }
    
    package static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeView(modifier: modifier, inputs: inputs, body: body)
    }
}

// MARK: - GestureFilter [6.5.4] [Blocked by ViewResponder]

private struct GestureFilter<Modifier>: StatefulRule where Modifier: GestureViewModifier {
    typealias Value = [ViewResponder]
    
    @Attribute var children: [ViewResponder]
    
    @Attribute var modifier: Modifier
    
    var inputs: _ViewInputs
    
    var viewSubgraph: Subgraph
    
    lazy var responder: GestureResponder<Modifier> = {
        viewSubgraph.apply {
            GestureResponder(
                modifier: $modifier,
                inputs: inputs
            )
        }
    }()
    
    mutating func updateValue() {
        let responder = responder
        let (children, childrenChanged) = $children.changedValue()
        if childrenChanged {
            // responder.children = children
        }
        if !hasValue {
            // value = [self.responder]
        }
    }
}

// MARK: - AddGestureModifier [6.5.4]

package struct AddGestureModifier<T>: GestureViewModifier where T: Gesture {
    package var gesture: T
    package var name: String?
    package var gestureMask: GestureMask
    
    package init(
        _ gesture: T,
        name: String? = nil,
        gestureMask: GestureMask = .all
    ) {
        self.gesture = gesture
        self.name = name
        self.gestureMask = gestureMask
    }
    
    package typealias Combiner = DefaultGestureCombiner

    package typealias ContentGesture = T
}

package struct DefaultGestureCombiner: GestureCombiner {
    package typealias Base = ExclusiveGesture<AnyGesture<Void>, AnyGesture<Void>>

    package typealias Result = _MapGesture<DefaultGestureCombiner.Base, Int>

    package static var exclusionPolicy: GestureResponderExclusionPolicy { .default }

    package static func combine(
        _ first: AnyGesture<Void>,
        _ second: AnyGesture<Void>
    ) -> DefaultGestureCombiner.Result {
        preconditionFailure("TODO")
    }
}

package protocol AnyGestureContainingResponder: ViewResponder {
    var viewSubgraph: Subgraph { get }
    var eventSources: [any EventBindingSource] { get }
    var gestureType: any Any.Type { get }
    var isValid: Bool { get }
    
    func detachContainer()
}

package protocol AnyGestureResponder: AnyGestureContainingResponder {
    var inputs: _ViewInputs { get }
    var childSubgraph: Subgraph? { get set }
    var childViewSubgraph: Subgraph? { get set }
    var exclusionPolicy: GestureResponderExclusionPolicy { get }
    var gestureGraph: GestureGraph { get }
    
    func makeSubviewsGesture(inputs: _GestureInputs) -> _GestureOutputs<Void>
}

extension AnyGestureResponder {
    package var exclusionPolicy: GestureResponderExclusionPolicy {
        get { preconditionFailure("TODO") }
    }
    
    package func makeSubviewsGesture(inputs: _GestureInputs) -> _GestureOutputs<Void> {
        preconditionFailure("TODO")
    }
    
    package func makeWrappedGesture(
        inputs: _GestureInputs,
        makeChild: (_GestureInputs) -> _GestureOutputs<Void>
    ) -> _GestureOutputs<Void> { preconditionFailure("TODO") }
    
    package var label: String? {
        get { preconditionFailure("TODO") }
    }
    
    package var isCancellable: Bool {
        get { preconditionFailure("TODO") }
    }
    
    package var requiredTapCount: Int? {
        get { preconditionFailure("TODO") }
    }
    
    package func canPrevent(
        _ other: ViewResponder,
        otherExclusionPolicy: GestureResponderExclusionPolicy
    ) -> Bool { preconditionFailure("TODO") }
    
    package func shouldRequireFailure(of other: any AnyGestureResponder) -> Bool {
        preconditionFailure("TODO")
    }
}

private class GestureResponder<Modifier>/*: AnyGestureResponder where Modifier: GestureViewModifier*/ {
    init(modifier: Attribute<Modifier>, inputs: _ViewInputs) {
        preconditionFailure("TODO")
    }
}

// MARK: - GestureAccessibilityProvider [6.5.4]

package protocol GestureAccessibilityProvider {
    nonisolated static func makeGesture(
        mask: @autoclosure () -> Attribute<GestureMask>,
        inputs: _ViewInputs,
        outputs: inout _ViewOutputs
    )
}

private struct GestureAccessibilityProviderKey: GraphInput {
    static let defaultValue: (any GestureAccessibilityProvider.Type) = EmptyGestureAccessibilityProvider.self
}

struct EmptyGestureAccessibilityProvider: GestureAccessibilityProvider {
    nonisolated static func makeGesture(
        mask: @autoclosure () -> Attribute<GestureMask>,
        inputs: _ViewInputs,
        outputs: inout _ViewOutputs
    ) {
    }
}

extension _GraphInputs {
    package var gestureAccessibilityProvider: (any GestureAccessibilityProvider.Type) {
        get { self[GestureAccessibilityProviderKey.self] }
        set { self[GestureAccessibilityProviderKey.self] = newValue }
    }
}

extension _ViewInputs {
    package var gestureAccessibilityProvider: (any GestureAccessibilityProvider.Type) {
        get { base.gestureAccessibilityProvider }
        set { base.gestureAccessibilityProvider = newValue }
    }
}

// MARK: - Optional: Gesture [WIP]

extension Optional: Gesture where Wrapped: Gesture {
    public typealias Value = Wrapped.Value
    
    nonisolated public static func _makeGesture(
        gesture: _GraphValue<Optional<Wrapped>>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Wrapped.Value> {
        preconditionFailure("TODO")
    }

    public typealias Body = Never
}

extension Optional: PrimitiveGesture where Wrapped: Gesture {}
