//
//  ViewRespondersKey.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Empty

package struct ViewRespondersKey: PreferenceKey {
    package static var defaultValue: [ViewResponder] { [] }
    
    package static var _includesRemovedValues: Bool { true }
    
    package static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

// TODO

@_spi(ForOpenSwiftUIOnly)
open class ViewResponder/*: ResponderNode, CustomStringConvertible, CustomRecursiveStringConvertible*/ {
}

package struct HitTestBindingModifier: ViewModifier, /*MultiViewModifier,*/ PrimitiveViewModifier {
    nonisolated package static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        // preconditionFailure("TODO")
        makeDebuggableView(modifier: modifier, inputs: inputs, body: body)
    }
    
    package typealias Body = Never
}
