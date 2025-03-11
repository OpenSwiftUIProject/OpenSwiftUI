//
//  _AnimatableView.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Blocked by Graph

package import OpenGraphShims

@available(*, deprecated, message: "use Animatable directly")
public protocol _AnimatableView: Animatable, View {}

@available(*, deprecated, message: "use Animatable directly")
extension _AnimatableView {
    public static func _makeView(view _: _GraphValue<Self>, inputs _: _ViewInputs) -> _ViewOutputs {
        .init()
    }

    public static func _makeViewList(view _: _GraphValue<Self>, inputs _: _ViewListInputs) -> _ViewListOutputs {
        preconditionFailure("TODO")
    }
}

extension View where Self: Animatable {
    public static func _makeView(view _: _GraphValue<Self>, inputs _: _ViewInputs) -> _ViewOutputs {
        .init()
    }

    public static func _makeViewList(view _: _GraphValue<Self>, inputs _: _ViewListInputs) -> _ViewListOutputs {
        preconditionFailure("TODO")
    }
}

package struct AnimatableAttribute<Value>: StatefulRule, AsyncAttribute, ObservedAttribute, CustomStringConvertible where Value: Animatable {
    package init(source: Attribute<Value>, phase: Attribute<_GraphInputs.Phase>, time: Attribute<Time>, transaction: Attribute<Transaction>, environment: Attribute<EnvironmentValues>) {
        preconditionFailure("TODO")
    }
    
    package mutating func updateValue() {
        preconditionFailure("TODO")
    }

    package var description: String {
        preconditionFailure("TODO")
    }

    // FIXME: ObservedAttribute destroy requirement should be mutating
    package /*mutating*/ func destroy() {
        preconditionFailure("TODO")
    }
}
